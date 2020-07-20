# 配列を方程式に変形
def to_equation(arr)
  text = ""
  arr.each_with_index do |v, i|
    v == 1 ? text += "1" : text += "x^#{v}"
    text += " + " unless i == arr.size - 1
  end
  text
end

# シンドロームの計算
def syndrome(m, t, y)
  puts "--- 受信 ---"
  puts "受診語: y(x) = #{to_equation(y)}"

  # ビットマップ作成
  map = { "0" => 0, "z0" => 1 } # z0 = 1 (便宜上、"z0"としてる)
  (1..(2**m - 2)).each do |i|
    map["z#{i}"] = i <= m - 1 ? 2**i : map["z#{i - (m - 1)}"] ^ map["z#{i - m}"]
  end

  s = (2 * t).times.map do |i|
    total = map["z#{(y[0] * (i + 1)) % (2**m - 1)}"]

    # ビットごとの排他的論理和を計算
    (1..(y.size - 1)).each do |j|
      a = total.to_s(2).rjust(m, "0").split("")
      b = map["z#{(y[j] * (i + 1)) % (2**m - 1)}"].to_s(2).rjust(m, "0").split("")

      total = a.each_with_index.map do |v, idx|
        (a[idx].to_i ^ b[idx].to_i).to_s
      end.join.to_i(2)
    end

    total
  end
  s
end

# 誤り位置多項式を導出
def error_position(s)

end

# 有限体GF(2^m)
ans = [1, 4, 6, 7, 8]

m = 4
dist = 5                  # 設計距離: 2個以下の誤りを訂正できる最小値
t = ((dist - 1) / 2).to_i # 訂正可能な誤りの個数
n = 2**m - 1              # 符号長
kiyaku = [0, 1, 4]        # 規約多項式: 1 + x + x**4
e = [7, 8]                # 誤り箇所(2箇所): x**7 + x**8
y = [0, 4, 6]             # 受信語: 1 + x**4 + x**6

puts "--- 送信 ---"
puts "符号語: #{to_equation(ans)}"

p s = syndrome(m, t, y)
# err_pos = error_position(s)

