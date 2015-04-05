# coding: utf-8

require './expression.rb'
require 'pry'

# ポーランド記法の式を展開します。
def get_expand_exp rpn_exp

  expand_exp = ""
  stack = []
  left_exp = ""
  right_exp = ""
  rpn_exp.split(" ").each.with_index{|token, index|
    if /[\+\-\*\/]/ =~ token then

      # stackが1つしかない場合は左辺のみ設定
      if stack.length == 1 then
        left_exp = stack.pop
      else
        right_exp = stack.pop
        left_exp = stack.pop
      end

      # 先頭が-の場合を考慮
      if token == "-" && index == 1 then
        stack.push(token + left_exp)
        next
      end

      # 計算処理の実行
      if token == "\+" || token == "-" then
        stack.push Calculation.add_sub(left_exp, right_exp, token)
      else
        stack.push Calculation.multipl(left_exp, right_exp, token)
      end

    else
      stack.push(token)
    end
  }
  return expand_exp
end

# 1行目(式)の読み込み
exp = gets.chomp

# 取得した式を逆ポーランド記法へ変換
rpn_exp = Rpn.get_rpn exp
expand_exp = get_expand_exp rpn_exp

# 空行Read
gets

# 式が存在する分だけ演算を行う。
while gets != nil do
  # 引数から 変数=>値 のハッシュへ変換
  val_hash = {}
  $_.chomp.split(",").each{|param_list|
    param_exp = param_list.split("=")
    val_hash[param_exp[0]] = param_exp[1]
  }

  # TODO

end

