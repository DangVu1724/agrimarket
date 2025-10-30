import 'package:agrimarket/core/widgets/custom_text_form_field.dart';
import 'package:agrimarket/data/models/discount_code.dart';
import 'package:agrimarket/data/models/product_promotion.dart';
import 'package:agrimarket/features/seller/home/viewmodel/seller_home_screen_vm.dart';
import 'package:agrimarket/features/seller/promotion/viewmodel/promotion_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogPromotion extends StatefulWidget {
  final String type; // 'code' hoặc 'product'
  final DiscountCodeModel? discountCodeModel;
  final ProductPromotionModel? productPromotionModel;

  const DialogPromotion({super.key, required this.type, this.discountCodeModel, this.productPromotionModel});

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

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    codeController.dispose();
    percentController.dispose();
    minOrderController.dispose();
    productIdsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final isCode = widget.type == 'code';

    if (isCode && widget.discountCodeModel != null) {
      final model = widget.discountCodeModel!;
      codeController.text = model.code;
      percentController.text = model.value.toString();
      minOrderController.text = model.minOrder.toString();
      selectedDiscountType = model.discountType;
      _startDate = model.startDate;
      _endDate = model.expiredDate;
    } else if (!isCode && widget.productPromotionModel != null) {
      final model = widget.productPromotionModel!;
      percentController.text = model.discountValue.toString();
      selectedDiscountType = model.discountType;
      _startDate = model.startDate;
      _endDate = model.endDate;
    }
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

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => _selectDate(context, true),
                child: AbsorbPointer(
                  child: CustomTextFormField(
                    label: 'Ngày bắt đầu',
                    hintText: 'Chọn ngày bắt đầu',
                    controller: TextEditingController(
                      text: _startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : '',
                    ),
                    validator: (value) {
                      if (_startDate == null) return 'Vui lòng chọn ngày bắt đầu';
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => _selectDate(context, false),
                child: AbsorbPointer(
                  child: CustomTextFormField(
                    label: 'Ngày kết thúc',
                    hintText: 'Chọn ngày kết thúc',
                    controller: TextEditingController(
                      text: _endDate != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : '',
                    ),
                    validator: (value) {
                      if (_endDate == null) return 'Vui lòng chọn ngày kết thúc';
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedDiscountType,
                hint: const Text('Chọn loại giảm giá'),
                decoration: InputDecoration(
                  labelText: 'Loại giảm giá',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items:
                    discountTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type == 'percent' ? 'Phần trăm' : 'Giảm cố định'),
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
                Get.snackbar(
                  'Lỗi',
                  'Ngày kết thúc phải sau ngày bắt đầu.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              if (isCode) {
                widget.discountCodeModel != null ? _updateDiscountCode() : _createDiscountCode();
              } else {
                widget.productPromotionModel != null ? _updateProductPromotion() : _createProductPromotion();
              }
              Navigator.pop(context);
            }
          },

          child: Text(widget.discountCodeModel != null || widget.productPromotionModel != null ? 'Lưu' : 'Tạo'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
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
      storeId: sellerHomeVm.store.value?.storeId != null ? [sellerHomeVm.store.value!.storeId] : [],
      creatorRole: 'seller',
      discountType: selectedDiscountType ?? 'percent',
      value: double.parse(percentController.text.trim()),
      minOrder: double.parse(minOrderController.text.trim()),
      startDate: _startDate ?? DateTime.now(),
      expiredDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      limit: 100,
      used: 0,
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
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      promotionId: null,
    );

    vm.addProductDiscount(model);
  }

  void _updateDiscountCode() {
    final updated = widget.discountCodeModel!.copyWith(
      code: codeController.text.trim(),
      value: double.parse(percentController.text.trim()),
      discountType: selectedDiscountType ?? 'percent',
      minOrder: double.parse(minOrderController.text.trim()),
      startDate: _startDate!,
      expiredDate: _endDate!,
    );
    vm.updateDiscountCode(updated);
  }

  void _updateProductPromotion() {
    final updated = widget.productPromotionModel!.copyWith(
      discountValue: double.parse(percentController.text.trim()),
      discountType: selectedDiscountType ?? 'percent',
      startDate: _startDate!,
      endDate: _endDate!,
    );
    vm.updateProductDiscount(updated);
  }
}
