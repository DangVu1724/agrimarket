import 'package:agrimarket/core/widgets/custom_text_form_field.dart';
import 'package:agrimarket/data/models/discount_code.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:agrimarket/features/seller/promotion/viewmodel/promotion_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class DialogPromotion extends StatefulWidget {
  final String type; // 'code' hoặc 'product'

  const DialogPromotion({super.key, required this.type});

  @override
  State<DialogPromotion> createState() => _DialogPromotionState();
}

class _DialogPromotionState extends State<DialogPromotion> {
  final formKey = GlobalKey<FormState>();

  final codeController = TextEditingController();
  final percentController = TextEditingController();
  final minOrderController = TextEditingController();
  final productIdsController = TextEditingController();
  final List<String> discountTypes = ['percent', 'fixed'];
  String? selectedDiscountType;

  final PromotionVm vm = Get.find<PromotionVm>();
  final SellerHomeVm sellerHomeVm = Get.find<SellerHomeVm>();

  @override
  void dispose() {
    codeController.dispose();
    percentController.dispose();
    minOrderController.dispose();
    productIdsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCode = widget.type == 'code';

    return AlertDialog(
      title: Text(isCode ? 'Tạo mã giảm giá' : 'Tạo giảm giá sản phẩm'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCode)
                CustomTextFormField(
                  controller: codeController,
                  label: 'Mã giảm giá',
                  hintText: 'Nhập mã code',
                  validator: _requiredValidator,
                ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: selectedDiscountType,
                hint: const Text('Chọn loại giảm giá'),
                decoration: InputDecoration(
                  labelText: 'Loại giảm giá',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    discountTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type == 'percent' ? 'Phần trăm' : 'Giảm cố định',
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDiscountType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn loại giảm giá';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              CustomTextFormField(
                controller: percentController,
                label: 'Giá trị giảm',
                hintText: 'Nhập phần trăm hoặc số tiền',
                keyboard: TextInputType.number,
                validator: _requiredValidator,
              ),
              if (isCode)
                CustomTextFormField(
                  controller: minOrderController,
                  label: 'Đơn tối thiểu',
                  hintText: 'Nhập giá trị đơn hàng tối thiểu',
                  keyboard: TextInputType.number,
                  validator: _requiredValidator,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              if (isCode) {
                _createDiscountCode();
              } else {
                _createProductPromotion();
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Tạo'),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Không được để trống';
    }
    return null;
  }

  void _createDiscountCode() {
    // final uuid = Uuid();

    // String newId = uuid.v4();
    final model = DiscountCodeModel(
      id: '',
      code: codeController.text.trim(),
      storeId: sellerHomeVm.store.value?.storeId,
      creatorRole: 'seller',
      creatorId: sellerHomeVm.store.value!.storeId,
      discountType: selectedDiscountType ?? 'percent',
      value: double.parse(percentController.text.trim()),
      minOrder: double.parse(minOrderController.text.trim()),
      startDate: DateTime.now(),
      expiredDate: DateTime.now().add(const Duration(days: 30)),
      limit: 100,
      used: 0,
      isActive: true,
      promotionId: null,
    );

    vm.addDiscountCode(model);
  }

  void _createProductPromotion() {
    // final uuid = Uuid();

    // String newId = uuid.v4();

    final model = ProductPromotionModel(
      id: '',
      storeId: sellerHomeVm.store.value!.storeId,
      productIds: const [],
      discountValue: double.parse(percentController.text.trim()),
      discountType: selectedDiscountType ?? 'percent',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      promotionId: null,
    );

    vm.addProductDiscount(model);
  }
}
