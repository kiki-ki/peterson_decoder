def syndrome(m, y, e)
  s = []
  map = { "0" => 0, "1" => 1 }
  (1..(2**m - 2)).each do |i|
    map["z#{i}"] = i <= m - 1 ?
      2**i : i == m ? map["z#{i - (m - 1)}"] ^ map["1"] : map["z#{i - (m - 1)}"] ^ map["z#{i - m}"]
  end
  map
end

puts syndrome(5, 1, 1)

# 有限体GF(2^m)
# m = 4
# n = 2^m - 1           # 符号長
# dist = 5              # 設計距離: 2個以下の誤りを訂正できる最小値
# kiyaku = 1 + x + x^4  # 規約多項式

# e = x^7 + x^8         # 誤り箇所(2箇所)
# y = 1 + x^4 + x^6     # 受信語


# s =
# z_map {
#   0: 0b0000, 1: 0b0001,
# }
