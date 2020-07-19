def syndrome(m, t, y, e)
  # ビットマップ作成
  map = { "0" => 0, "z0" => 1 } # z0: 1 (便宜上、"z0"としている)
  (1..(2**m - 2)).each do |i|
    map["z#{i}"] = i <= m - 1 ? 2**i : map["z#{i - (m - 1)}"] ^ map["z#{i - m}"]
  end

  # シンドローム計算
  s = (2 * t).times.map do
    total = map["z#{y[0]}"]

    # ビットごとの排他的論理和を計算
    (1..(y.size - 1)).each do |i|
      total_arr = total.to_s(2).rjust(m, "0").split("")
      map_arr = map["z#{y[i]}"].to_s(2).rjust(m, "0").split("")

      total = total_arr.each_with_index.map do |v, idx|
        (total_arr[idx].to_i ^ map_arr[idx].to_i).to_s
      end.join.to_i(2)
    end

    total
  end
  p s
end


# 有限体GF(2^m)
m = 4
dist = 5                  # 設計距離: 2個以下の誤りを訂正できる最小値
t = ((dist - 1) / 2).to_i # 訂正可能な誤りの個数
n = 2**m - 1              # 符号長
kiyaku = [0, 1, 4]        # 規約多項式: 1 + x + x**4
e = [7, 8]                # 誤り箇所(2箇所): x**7 + x**8
y = [0, 4, 6]             # 受信語: 1 + x**4 + x**6

puts syndrome(m, t, y, e)