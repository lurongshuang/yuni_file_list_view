#include "include/yuni_file_list_view/yuni_file_list_view_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "yuni_file_list_view_plugin.h"

void YuniFileListViewPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  yuni_file_list_view::YuniFileListViewPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
