require 'ffi'

module PCProxLib
  extend FFI::Library
  ffi_lib File.expand_path('lib/32/libhidapi-hidraw.so.0')
  ffi_lib File.expand_path('lib/32/libpcProxAPI.so')
  attach_function :usbConnect, [], :short
  attach_function :USBDisconnect, [], :short
  attach_function :getPartNumberString, [], :string
  attach_function :getActiveID32, [:pointer, :short], :short
  attach_function :GetQueuedID, [:short, :short], :short
  attach_function :GetQueuedID_index, [:short], :long
end

# Will connect to first reader found
PCProxLib.usbConnect()

puts PCProxLib.getPartNumberString()

card_number = ""

# Check if GetQueuedID is available for this reader
get_queued_id_available = PCProxLib.GetQueuedID(1, 0)

if get_queued_id_available == false
  abort("GetQueuedID is not available.")
end

# index 32 returns the number of bits read
bits_read = PCProxLib.GetQueuedID_index(32)

puts "Bits read: #{bits_read}"

# calculate bytes to read
bytes_to_read = (bits_read + 7) / 8

# read a minimum of at least 8 bytes
bytes_to_read = 8 if bytes_to_read < 8

bytes_to_read.times do |i|
  
  # get the card number chunk from index i
  tmp = PCProxLib.GetQueuedID_index(i)
  
  # convert the card number chunk to hex
  tmp = tmp.to_s(16)
  
  # pad the hex value with leading zeros, if needed
  tmp = tmp.rjust(2, '0')
  
  # add the hex value to the beginning of the card number string
  card_number = tmp + card_number
end

if bits_read == 32
  # regular swipe card, need to do some magic to get the actual number
  card_number_as_int = Integer("0x#{card_number}")
  return card_number_as_int
else
  # no magic needed, just strip off any leading zeros
  card_number_as_int = card_number.sub(/^0*/, '')
  return card_number_as_int
else
  return 0
end

PCProxLib.USBDisconnect()