import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sample_data.dart';
import '../state/cart_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/glass.dart';
import 'cart_screen.dart';

/// Always scrollable so pull-to-refresh works even with few (or no) items.
const _physics = AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<Product> _products = [...seedProducts];
  bool _grid = false;

  Future<void> _refresh() async {
    // Simulated network request; reloading brings back the starter items.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    _restore();
  }

  void _remove(Product p) {
    final index = _products.indexOf(p);
    setState(() => _products.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Removed "${p.title}"',
            style: const TextStyle(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.orangeLight,
            onPressed: () {
              // Skip if the screen is gone or a restore already brought it back.
              if (!mounted || _products.any((x) => x.id == p.id)) return;
              setState(
                () => _products.insert(index.clamp(0, _products.length), p),
              );
            },
          ),
        ),
      );
  }

  void _restore() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(
      () => _products
        ..clear()
        ..addAll(seedProducts),
    );
  }

  Widget _dismissible(
    Product p, {
    required double radius,
    required Widget child,
  }) {
    return Dismissible(
      key: ValueKey(p.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _remove(p),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_products.isEmpty) {
      body = _EmptyCatalog(key: const ValueKey('empty'), onRestore: _restore);
    } else if (_grid) {
      body = GridView.builder(
        key: const ValueKey('grid'),
        physics: _physics,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.74,
        ),
        itemCount: _products.length,
        itemBuilder: (_, i) => _dismissible(
          _products[i],
          radius: 26,
          child: _ProductCard(product: _products[i]),
        ),
      );
    } else {
      body = ListView.separated(
        key: const ValueKey('list'),
        physics: _physics,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
        itemCount: _products.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.white.withValues(alpha: 0.25),
        ),
        itemBuilder: (_, i) => _dismissible(
          _products[i],
          radius: 18,
          child: _ProductRow(product: _products[i]),
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: ScreenHeader(
              title: 'Catalog',
              onBack: widget.onBack,
              trailing: CartBadgeButton(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CartScreen()),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: SectionHeader(
                    title: _grid ? 'Grid catalog' : 'List feed',
                    action: '${_products.length} items',
                  ),
                ),
                const SizedBox(width: 12),
                GlassCircleButton(
                  size: 40,
                  icon: _grid
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  onTap: () => setState(() => _grid = !_grid),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.ink,
              backgroundColor: Colors.white,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: product.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(product.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          product.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _Rating(rating: product.rating, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPrice(product.price),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              _CartToggle(product: product),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 26,
      opacity: 0.55,
      borderOpacity: 0.6,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    product.color.withValues(alpha: 0.75),
                    product.color,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(product.icon, color: Colors.white, size: 44),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: StatusChip(label: product.category),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _CartToggle(product: product),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Rating(rating: product.rating, color: AppColors.ink),
                    const SizedBox(width: 6),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatPrice(product.price),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Add to Cart" pill that flips to "In cart" while the product is selected.
class _CartToggle extends StatelessWidget {
  const _CartToggle({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final inCart = context.select<CartProvider, bool>(
      (c) => c.contains(product),
    );
    return Pressable(
      onTap: () => context.read<CartProvider>().toggle(product),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: inCart ? AppColors.orange : AppColors.ink,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              inCart ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              inCart ? 'In cart' : 'Add to Cart',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rating, required this.color});

  final double rating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 15, color: AppColors.orange),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({super.key, required this.onRestore});

  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: _physics,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 130),
      children: [
        Glass(
          opacity: 0.12,
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 12),
              const Text('Catalog is Empty', style: AppText.section),
              const SizedBox(height: 6),
              Text(
                'Restore the starter items, or pull down to reload the catalog.',
                textAlign: TextAlign.center,
                style: AppText.caption.copyWith(height: 1.35, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Restore catalog',
                  icon: Icons.refresh_rounded,
                  onTap: onRestore,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
