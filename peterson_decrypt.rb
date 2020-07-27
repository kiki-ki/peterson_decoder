module ArrayClassExtention
  # 配列を方程式に変形
  def to_equation
    text = ""
    self.each_with_index do |v, i|
      v == 0 ? text += "1" : text += "x^#{v}"
      text += " + " unless i == self.size - 1
    end
    text
  end
end
Array.prepend(ArrayClassExtention)

module IntegerClassExtention
  # 2元の文字列に変換
  def to_bit(m)
    self.to_s(2).rjust(m, "0")
  end

  # bitごとの配列に変換
  def to_bit_arr(m)
    self.to_bit(m).split("")
  end
end
Integer.prepend(IntegerClassExtention)

class Peterson
  attr_reader :m, :t, :y, :bitmap, :ans, :e

  def initialize(ans:, m:, t:, y:, e:)
    @ans = ans
    @m = m
    @t = t
    @y = y
    @e = e
    @bitmap = bit_map(m)
  end

  def outputs
    puts "--- 送信 ---"
    puts "sent_code:             #{ans.to_equation}"
    puts "--- 受信 ---"
    puts "recieved_code:         #{y.to_equation}"
    puts "gave_err_position:     #{e.to_equation}"
    puts "--- 復号 ---"
    s = syndrome
    puts "detected_err_position: #{err_position(s).to_equation}"
    puts "decoded_result:        #{decode.to_equation}"
    puts "expected:              #{ans.to_equation}"
  end

  def decode
    s = syndrome
    err = err_position(s)
    duplication = y & err
    res = y | err
    duplication.each do |v|
      res.delete(v)
    end
    res
  end

  private

    # シンドロームの計算
    def syndrome
      s = (2 * t).times.map do |i|
        total = bitmap["z#{(y[0] * (i + 1)) % (2**m - 1)}"]
        # ビットごとの排他的論理和を計算
        (1..(y.size - 1)).each do |j|
          a = total.to_bit_arr(m)
          b = bitmap["z#{(y[j] * (i + 1)) % (2**m - 1)}"].to_bit_arr(m)

          total = sum_by_bit(a, b)
        end
        total
      end
      s
    end

    # 誤り位置多項式を導出
    def err_position(s)
      u = t
      a2 = u.times.map { |i| u.times.map { |j| s[i + j] } }
      until regular?(a2)
        u -= 1
        raise "unregular error" if u <= 0
        a2 = u.times.map { |i| u.times.map { |j| s[i + j] } }
      end

      case a2.size
      when 1
        [get_z_multiplier(s[0])]
      when 2
        z_multipliers = s.map { |v| get_z_multiplier(v) }

        err2 = sum_by_bit(
          bitmap["z#{(z_multipliers[2] + z_multipliers[2] - @z_multiplier_of_a2) % (2**m - 1)}"].to_bit_arr(m),
          bitmap["z#{(z_multipliers[1] + z_multipliers[3] - @z_multiplier_of_a2) % (2**m - 1)}"].to_bit_arr(m)
        )
        err1 = sum_by_bit(
          bitmap["z#{(z_multipliers[1] + z_multipliers[2] - @z_multiplier_of_a2) % (2**m - 1)}"].to_bit_arr(m),
          bitmap["z#{(z_multipliers[0] + z_multipliers[3] - @z_multiplier_of_a2) % (2**m - 1)}"].to_bit_arr(m)
        )

        z_multiplier_of_err2 = get_z_multiplier(err2)
        z_multiplier_of_err1 = get_z_multiplier(err1)

        err = []
        bitmap.each do |k, v|
          next if v == 0
          sum = sum_by_bit(
            bitmap["z#{(z_multiplier_of_err1 + get_z_multiplier(v)) % (2**m - 1)}"].to_bit_arr(m),
            bitmap["z#{(z_multiplier_of_err2 + get_z_multiplier(v) * 2) % (2**m - 1)}"].to_bit_arr(m)
          )
          err << (2**m - 1) - get_z_multiplier(v) if sum - 1 == 0
        end

        err.sort
      end
    end

    # ビットマップ作成
    def bit_map(m)
      map = { "0" => 0, "z0" => 1 } # z0 = 1 (便宜上、"z0"としてる)
      (1..(2**m - 2)).each do |i|
        map["z#{i}"] = i <= m - 1 ? 2**i : map["z#{i - (m - 1)}"] ^ map["z#{i - m}"]
      end
      map
    end

    def regular?(a2)
      return false unless a2.size == a2.first.size

      case a2.size
      when 1
        a2[0][0] != 0
      when 2
        z_multipliers = a2.map { |arr| arr.map { |v| get_z_multiplier(v) } }
        a = bitmap["z#{(z_multipliers[0][0] + z_multipliers[1][1]) % (2**m - 1)}"].to_bit_arr(m)
        b = bitmap["z#{(z_multipliers[0][1] + z_multipliers[1][0]) % (2**m - 1)}"].to_bit_arr(m)
        a2 = sum_by_bit(a, b)
        @z_multiplier_of_a2 = bitmap.key(a2).delete("z").to_i

        a2 != 0
      else
        raise "matrix size error. in preperation."
      end
    end

    def sum_by_bit(a, b)
      a.each_with_index.map do |v, idx|
        (a[idx].to_i ^ b[idx].to_i).to_s
      end.join.to_i(2)
    end

    def get_z_multiplier(val)
      bitmap.key(val).delete("z").to_i
    end
end

# 有限体GF(2^m)
ans = [0, 4, 6, 7, 8]
m = 4
n = 2**m - 1              # 符号長
dist = 5                  # 設計距離: 2個以下の誤りを訂正できる最小値
t = ((dist - 1) / 2).to_i # 訂正可能な誤りの個数
y = [0, 4, 6]             # 受信語: 1 + x**4 + x**6
kiyaku = [0, 1, 4]        # 規約多項式: 1 + x + x**4
e = [7, 8]                # 誤り箇所(2箇所): x**7 + x**8

Peterson.new(
  ans: ans,
  m: m,
  t: t,
  y: y,
  e: e
).outputs
