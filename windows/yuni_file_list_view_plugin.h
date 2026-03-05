#ifndef FLUTTER_PLUGIN_YUNI_FILE_LIST_VIEW_PLUGIN_H_
#define FLUTTER_PLUGIN_YUNI_FILE_LIST_VIEW_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace yuni_file_list_view {

class YuniFileListViewPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  YuniFileListViewPlugin();

  virtual ~YuniFileListViewPlugin();

  // Disallow copy and assign.
  YuniFileListViewPlugin(const YuniFileListViewPlugin&) = delete;
  YuniFileListViewPlugin& operator=(const YuniFileListViewPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace yuni_file_list_view

#endif  // FLUTTER_PLUGIN_YUNI_FILE_LIST_VIEW_PLUGIN_H_
