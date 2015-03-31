# coding:utf-8

# 逆ポーランド記法モジュール
module Rpn
  # 逆ポーランド記法への変換
  def self.get_rpn exp

    # 優先度を定義する
    priority_list = {
      "(" => 3,
      ")" => 3,
      "*" => 2,
      "/" => 2,
      "+" => 1,
      "-" => 1,
    }

    # 逆ポーランド記法化する式
    rpn_exp = ""
    # 演算子のスタック
    stack = []

    exp_str_list = exp.split("")

    exp_str_list.each.with_index{|token, index|

      # 数字 or アルファベットの場合
      if /[0-9a-z]/ =~ token then
        rpn_exp << token

        # 次の要素が数字orアルファベット以外で
        # 計算用演算子がスタックに存在する場合、Popする。
        if /[0-9a-z]/ =~ exp_str_list[index + 1] then
          next
        else
          rpn_exp << " "
        end

        if !stack.empty? then
          poped_token = stack.pop
          if /[\+\-\*\/]/ =~ poped_token then

            # 次の演算子と比較する。
            next_operator = nil
            for i in index..exp_str_list.length do
              if /[\+\-\*\/]/ =~ exp_str_list[i] then
                next_operator = exp_str_list[i]
                break
              end
            end

            # 次の演算子よりも優先度が高ければ式に追加する
            if next_operator != nil && (priority_list[next_operator] <= priority_list[poped_token]) then
              rpn_exp << poped_token
              rpn_exp << " "
            else
              stack.push(poped_token)
            end

          else
            stack.push(poped_token)
          end
        end
      # 演算子の場合
      elsif /[\+\-\*]/ =~ token then
        stack.push(token)

      # "("の場合、スタックする。
      elsif token == "(" then
        stack.push(token)

      # ")"の場合、"("までPopする。"()"はこのタイミングで破棄する。
      elsif token == ")" then
        poped_token = stack.pop
        while poped_token != "(" do
          rpn_exp << poped_token
          rpn_exp << " "
          poped_token = stack.pop
        end
        # "("の直前の演算子が"("以外ならpopする
        if !stack.empty? && stack[stack.length - 1] !="(" then
          rpn_exp << stack.pop
          rpn_exp << " "
        end
      end
    }

    # stackが空になるまでPOPし、rpn_expへ
    poped_token = stack.pop
    while poped_token != nil do
      rpn_exp << poped_token
      rpn_exp << " "
      poped_token = stack.pop
    end

    # 最後にブランクが含まれる場合、除外する。
    if rpn_exp[-1] == " " then
      rpn_exp.slice!(-1)
    end

    return rpn_exp
  end
end

# 計算モジュール
module Calculation

  # 数値型判定
  def self.integer_string? str
    Integer(str)
    true
  rescue ArgumentError
    false
  end

  # 加算処理
  def self.add left_exp, right_exp
    if integer_string?(left_exp) && integer_string?(right_exp) then
      return left_exp.to_i + right_exp.to_i
    end
  end

  # 減算処理
  def self.sub left_exp, right_exp
    puts "minus"

  end

  # 乗算処理
  def self.multipl left_exp, right_exp
    puts "multipl"

  end
end
