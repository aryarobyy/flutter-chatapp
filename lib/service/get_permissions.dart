import 'package:chat_app/component/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class GetPermissions {

  static Future<bool> getCameraPermission(BuildContext context) async {
    PermissionStatus permissionStatus = await Permission.camera.status;

    if (permissionStatus.isGranted){
      return true;
    } else if (permissionStatus.isDenied) {
      Permission status = (await Permission.camera.request()) as Permission;
      if(await status.isGranted) {
        return true;
      } else {
        showSnackBar(context, 'Camera permission is required');
        return true;
      }
    }
    return false;
  }

  static Future<bool> getStoragePermission(BuildContext context) async {
    Permission permissionStatus = (await Permission.storage.status) as Permission;

    if(await permissionStatus.isGranted){
      return true;
    } else if (await permissionStatus.isDenied) {
      Permission status = (await Permission.storage.request()) as Permission;
      if(await status.isGranted){
        return true;
      } else {
        showSnackBar(context, "Storage permission is required");
        return true;
      }
    }
    return false;
  }

}