import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import '../../shared/widgets.dart';

class MediaUtils {
  Future<XFile?> pickImage({required BuildContext context}) async {
    try {
      ImagePicker picker = ImagePicker();
      ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Avatar',
                  style: AppTextStyle.subTitle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Ionicons.camera_outline,
                      color: AppColors.primaryColor,
                    ),
                    title: const Text("Take a Photo"),
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                    trailing: const Icon(
                      Ionicons.chevron_forward_outline,
                      color: AppColors.flimsyGrey,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Ionicons.images_outline,
                      color: AppColors.primaryColor,
                    ),
                    title: const Text("Choose from Album"),
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                    trailing: const Icon(
                      Ionicons.chevron_forward_outline,
                      color: AppColors.flimsyGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                  bgColor: AppColors.error,
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return null;

      final file = await picker.pickImage(source: source, imageQuality: 30);
      return file;
    } catch (e) {
      return null;
    }
  }
}
