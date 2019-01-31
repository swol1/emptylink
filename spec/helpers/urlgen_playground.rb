# Test script to estimate random key length tresholds
# (c) goodprogrammer.ru
#
# Current results:
# key size 2 = 3rd confilct starts after ~500 keys
# key size 3 = 3rd confilct starts after ~7000 keys / x 14
# key size 4 = 3rd confilct starts after ~200 000 keys / x 16
# key size 5 = 3rd confilct starts after ~5 000 000 keys / x 16
#
require 'securerandom'

arr = []
loop do
  rnd = SecureRandom.urlsafe_base64(5).tr('lIO0', 'sxyz')
  if arr.include?(rnd)
    puts "size: #{arr.size}"
    sleep 0.5
  else
    arr << rnd
  end

  if arr.size % 100_000 == 0
    puts "hundred: #{arr.size}"
  end
end
