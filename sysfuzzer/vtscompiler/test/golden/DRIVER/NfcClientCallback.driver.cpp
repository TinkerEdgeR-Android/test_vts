#include "hardware/interfaces/nfc/1.0/vts/NfcClientCallback.vts.h"
#include "hardware/interfaces/nfc/1.0/vts/types.vts.h"
#include <hidl/HidlSupport.h>
#include <iostream>
#include "vts_datatype.h"
#include "vts_measurement.h"
#include <android/hardware/nfc/1.0/INfcClientCallback.h>
#include <android/hardware/nfc/1.0/types.h>
#include <android/hardware/nfc/1.0/INfcClientCallback.h>
#include <android/hardware/nfc/1.0/types.h>
#include <android/hardware/nfc/1.0/types.h>
using namespace android::hardware;
using namespace android::hardware::nfc::V1_0;
namespace android {
namespace vts {




Return<void> VtsNfcClientCallback::sendEvent(
    nfc_event_t arg0,
    nfc_status_t arg1) {
  cout << "sendEvent called" << endl;
  return Void();
}

Return<void> VtsNfcClientCallback::sendData(
    const nfc_data_t& arg0) {
  cout << "sendData called" << endl;
  return Void();
}

VtsNfcClientCallback* VtsFuzzerCreateINfcClientCallback(const string& callback_socket_name) {
  return new VtsNfcClientCallback();
}

}  // namespace vts
}  // namespace android
