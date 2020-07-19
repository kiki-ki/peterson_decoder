module Bch
  module Mod2
    G = 0b111010001 # 生成多項式:x^8+x7^+x^6+x^4+1

    module_function

    def rem_g(x)
      shift = count_leading_zero(G) - count_leading_zero(x)
      p x ^= G << shift while shift.negative?
      x
    end

    def count_leading_zero(num)
      cnt = 0
      num.to_s(2).split('').each do |n|
        n == '0' ? cnt += 1 : break
      end
      cnt
    end

    private_class_method :count_leading_zero
  end

  module_function

  def encode(num)
    shifted = num << 8
    shifted + Mod2.rem_g(shifted)
  end
end

p format("%015d", Bch.encode(0b101).to_s(2))

# RubyでBCH符号のセッティング（長さ10以上20以下ぐらい？、既約多項式、設定距離は中田君にお任せ）、ピーターソン法の実装をする。
# (15,8)BCH符号
