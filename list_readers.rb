require 'ffi'

module PCProxLib
  extend FFI::Library
  ffi_lib File.expand_path('lib/32/libhidapi-hidraw.so.0')
  ffi_lib File.expand_path('lib/32/libpcProxAPI.so')
  attach_function :usbConnect, [], :short
  attach_function :USBDisconnect, [], :short
  attach_function :SetDevTypeSrch, [:short], :short
  attach_function :GetDevCnt, [], :short
  attach_function :SetActDev, [:short], :short
  attach_function :getPartNumberString, [], :string
  attach_function :GetVidPidVendorName, [], :string
  attach_function :GetLUID, [], :short
  attach_function :getESN, [], :string
end

def get_devices_count
  # returns the total number of connected rfideas readers.
  number_of_devices = PCProxLib.GetDevCnt()
  return number_of_devices
end

def usb_connect
  # opens connection to all rfideas readers/devices
  # returns true in case success, false otherwise
  rc = PCProxLib.usbConnect()
  if rc == 1
    return true
  else
    return false
  end
end

def set_active_device(device)
  # returns true if able to set active device, otherwise false
  rc = PCProxLib.SetActDev(device)
  if rc == 1
    return true
  else
    return false
  end
end

def get_part_number
  # returns the part number of active device
  # pcproxlib.getPartNumberString.restype = ctypes.POINTER(ctypes.c_char)
  part_number = PCProxLib.getPartNumberString()
  # if partNb_p == None:
  #     return None;
  # else:
  #  return ctypes.string_at(partNb_p).decode('utf-8')
  return part_number
end

def get_vid_pid_vendor_name
  # returns the VID PID and product name in following format - <VID>:<PID> <product name>
  vid_pid = PCProxLib.GetVidPidVendorName()
  return vid_pid
end

def get_luid
  # returns the LUID of active device/Reader
  luid = PCProxLib.GetLUID()
  return luid
end

def get_esn
  # returns a string that will contains the ESN from the reader
  esn = PCProxLib.getESN()
  return esn
end

def list_all_devices
  connect = usb_connect
  if connect == false
    puts "Error: couldn't connect to any card readers. Aborting."
    abort
  end
  number_of_devices = get_devices_count
  puts "Number of devices: #{number_of_devices}"
  if number_of_devices > 0
    puts "Found #{number_of_devices} devices!"
    0.upto(number_of_devices-1) do |device|
      puts "Connecting to device #{device}..."
      set_active_device(device)
      puts "Part number: #{get_part_number}"
      # puts "VID:PID Product name: #{get_vid_pid_vendor_name}"
      # puts "LUID: #{get_luid}"
      puts "ESN: #{get_esn}"
      puts "-----------------------------------------------"
    end
  else
    puts "Didn't find any devices! :("
  end
end

list_all_devices

