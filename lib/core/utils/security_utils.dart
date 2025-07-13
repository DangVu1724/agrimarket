import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class SecurityUtils {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Password validation
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Mật khẩu không được để trống';
    }

    if (password.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ thường';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải có ít nhất 1 số';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
    }
    return null;
  }

  // Phone number validation
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    return phoneRegex.hasMatch(phone);
  }

  // Input sanitization
  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'[<>"\  -  -]'), '');
  }

  // Hash password (for local storage)
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate secure random string
  static String generateSecureToken() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  // Validate file type
  static bool isValidImageFile(String fileName) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    return validExtensions.contains(extension);
  }

  // Validate file size (in bytes)
  static bool isValidFileSize(int fileSize, {int maxSizeMB = 5}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return fileSize <= maxSizeBytes;
  }

  // Rate limiting helper
  static bool isRateLimited(DateTime lastRequest, {int cooldownSeconds = 60}) {
    final now = DateTime.now();
    final difference = now.difference(lastRequest).inSeconds;
    return difference < cooldownSeconds;
  }
}
