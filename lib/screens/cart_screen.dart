import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sample_data.dart';
import '../state/cart_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/glass.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Palette.of(context).bgBottom,
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: ScreenHeader(
                    title: 'Cart',
                    onBack: () => Navigator.of(context).pop(),
                    trailing: const CartBadgeButton(),
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Selected items',
                    action: cart.isEmpty ? null : 'Clear All',
                    onAction: cart.isEmpty ? null : cart.clear,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: cart.isEmpty
                      ? const _EmptyCart()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                          itemCount: cart.count,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _CartRow(
                            product: cart.items[i],
                            onRemove: () => cart.remove(cart.items[i]),
                          ),
                        ),
                ),
                if (!cart.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Glass(
                      opacity: 0.55,
                      borderOpacity: 0.6,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Total (${cart.count} items)',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              Text(
                                formatPrice(cart.total),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              label: 'Clear All',
                              icon: Icons.delete_sweep_rounded,
                              onTap: cart.clear,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cart icon with a live item-count badge; opens the cart unless already there.
class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final count = context.select<CartProvider, int>((c) => c.count);
    return Badge.count(
      count: count,
      isLabelVisible: count > 0,
      backgroundColor: AppColors.orange,
      offset: const Offset(-2, 2),
      child: GlassCircleButton(icon: Icons.shopping_bag_outlined, onTap: onTap),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.product, required this.onRemove});

  final Product product;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 22,
      opacity: 0.16,
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      child: Row(
        children: [
          IconBubble(icon: product.icon, color: product.color, size: 46),
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
                const SizedBox(height: 4),
                Text(product.category, style: AppText.caption),
              ],
            ),
          ),
          Text(
            formatPrice(product.price),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          IconButton(
            tooltip: 'Remove ${product.title}',
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      children: [
        Glass(
          opacity: 0.12,
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 12),
              const Text('Your cart is empty', style: AppText.section),
              const SizedBox(height: 6),
              Text(
                'Add items from the catalog and they will show up here.',
                textAlign: TextAlign.center,
                style: AppText.caption.copyWith(height: 1.35, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Back to catalog',
                  icon: Icons.storefront_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
