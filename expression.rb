# coding:utf-8

require 'pry'

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
      rpn_exp.chop!
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

  # 数式から各変数のリストへ変換する。
  def self.exp_2_val_list exp
    exp_list = []
    exp_list_tmp = exp.split(" ")
    exp_list_tmp.each_with_index{|token, index|
    if token == "\-" then
      exp_list_tmp[index + 1] = "\-#{exp_list_tmp[index + 1]}"
    elsif token != "\+" then
      exp_list.push(token)
    end
    }
    return exp_list
  end

  # 文字列を数字部分と変数部分に分解する
  def self.split_num_str str
    ret_num = ""
    ret_str = ""

    if /[0-9]/ !~ str.slice(0) then
      return ret_num, str
    end

    str.chars.each_with_index{|token, index|
      if /[0-9]/ =~ token then
        ret_num << token
      else
        ret_str = str[index, str.length]
        break
      end
    }
    return ret_num, ret_str
  end

  # 右辺・左辺ともに変数を含む場合の加減算処理
  def self.add_sub_variable left_exp, right_exp, calc_type

    result = ""

    # 計算条件判定のため、一度変数のみに分割する。
    left_val = left_exp.delete("\-")
    while /[0-9]/ =~ left_val.chr do
      left_val.slice!(0)
    end
    right_val = right_exp.delete("\-")
    while /[0-9]/ =~ right_val.chr do
      right_val.slice!(0)
    end

    # 変数が同一であれば、加減算処理を行う。
    if left_val == right_val then

      # 変数を除外した項目同士で計算処理を行う。
      left_pre = left_exp.delete(left_val)
      right_pre = right_exp.delete(right_val)

      case left_pre
      when "" then
        left_pre = "1"
      when "\-" then
        left_pre = "\-1"
      end

      case right_pre
      when "" then
        right_pre = "1"
      when "\-" then
        right_pre = "\-1"
      end

      case calc_type
      when "\+" then
        result = (left_pre.to_i + right_pre.to_i).to_s
        if result == "0" then
          result = ""
         else
          result << left_val
        end 
      when "\-" then
        result = (left_pre.to_i - right_pre.to_i).to_s
        if result == "0" then
          result = ""
        elsif result == "\-1" then
          result = "\-#{left_val}"
        else
          result << left_val
        end 
      end

    # 変数が異なる場合
    else
      result = left_exp
      if right_exp.slice(0) == "\-" then
        if calc_type == "\+" then
          result << " \- #{right_exp.delete('\-')}"
        else
          result << " \+ #{right_exp.delete('\-')}"
        end
      else
        if calc_type == "\+" then
          result << " \+ #{right_exp}"
        else
          result << " \- #{right_exp}"
        end
      end
    end
    return result
  end

  # 多項式の加減算処理
  def self.polyromial_add_sub left_exp, right_exp, calc_type

    left_exp_list = left_exp.split(" ")
    right_exp_list = right_exp.split(" ")

    # 両辺とも単項目
    if left_exp_list.length == 1 && right_exp_list.length == 1 then
      result = add_sub_variable(left_exp, right_exp, calc_type)

    # 方辺または両辺とも複数項目
    else
      # TODO
      result = add_sub_variable(left_exp, right_exp, calc_type)
    end

    return result
  end

  # 加減算処理
  def self.add_sub left_exp, right_exp, calc_type

    left_int = integer_string?(left_exp)
    right_int = integer_string?(right_exp)
    result = ""

    # 両辺が数値の場合
    if left_int && right_int then
      result = (left_exp.to_i + right_exp.to_i).to_s

    # 左辺または右辺が数値の場合
    elsif left_int || right_int then

      # 左辺が数字でなければ、右辺と左辺を入れ替える。
      if left_int then
        left_exp, right_exp = right_exp, left_exp
      end

      # 左辺が単項目の変数のみの場合
      if left_exp.length == 1 then
        result = "#{left_exp} + #{right_exp}"
        return result
      end

        left_exp_list = left_exp.split(" ")
        left_exp_list.each.with_index{|token, index|

        # tokenが数字の場合
        if integer_string? token then
          if left_exp_list[index - 1] == "\-" then

            calc_val = right_exp.to_i - token.to_i
            if calc_val == 0 then
              result.slice!(-2, 2)
            elsif calc_val > 0 then
              result.slice!(-2, 2)
              result << "+ #{calc_val} "
            else
              result << "#{calc_val.abs} "
            end
          else
            calc_val = token.to_i + right_exp.to_i
            if calc_val != 0 then
              result << "#{calc_val.to_s} "
            end
          end

        # tokenが数字ではない場合
        else
          if /[a-z]/ =~ token then
            result << "#{token} "
          else
            if !result.empty? then
              result << "#{token} "
            end
          end
        end
      }
      result.chop!

    # 両辺が変数の場合
    else
      result = polyromial_add_sub(left_exp, right_exp, calc_type)
    end
    return result
  end








  # 単項目の乗算処理
  def self.multipl_single left_val, right_val
    left_int = integer_string?(left_val)
    right_int = integer_string?(right_val)

    # 両辺が数値の場合
    if left_int && right_int then
      return (left_val.to_i * right_val.to_i).to_s
    end

    left_pre = left_val.slice(0)
    right_pre = right_val.slice(0)

    result = ""

    if left_pre == "\-" && right_pre != "\-" then
      left_pre.delete!("\-")
      result << "\-"
    elsif left_pre != "\-" && right_pre == "\-" then
      right_pre.delete!("\-")
      result << "\-"
    end

    # 各項目をそれぞれ数字部と文字列部に分割
    left_num, left_str = split_num_str(left_val)
    right_num, right_str = split_num_str(right_val)

    if left_num != "" && right_num != "" then
      result << "#{(left_num.to_i * right_num.to_i).to_s}"
    elsif left_num == "" then
       result << right_num
    elsif right_num == "" then
      result << left_num
    end

    result_str = "#{left_str}#{right_str}"
    
    result << result_str
    
  end

  # 乗算処理
  def self.multipl left_exp, right_exp
    result = ""
    left_exp_list = exp_2_val_list(left_exp)
    right_exp_list = exp_2_val_list(right_exp)

    left_exp_list.each{|left_val|
      right_exp_list.each{|right_val|
          result << "#{multipl_single(left_val, right_val)} "
      }
    }

#    # 左辺または右辺が数値の場合
#    elsif left_int || right_int then
#
#      # 左辺が数字でなければ、右辺と左辺を入れ替える。
#      if right_int then
#        left_exp, right_exp = right_exp, left_exp
#      end
#
#      # 右辺が単項目の変数のみの場合
#      if right_exp.length == 1 then
#        result = "#{left_exp}#{right_exp}"
#        return result
#      end
#
#        right_exp_list = right_exp.split(" ")
#        right_exp_list.each.with_index{|token, index|
#
#        # tokenが数字の場合
#        if integer_string? token then
#
#          calc_val = left_exp.to_i * token.to_i
#          if right_exp_list[index - 1] == "\-" then
#
#            if calc_val == 0 then
#              result.slice!(-2, 2)
#            elsif calc_val < 0 then
#              result.slice!(-2, 2)
#              result << "+ #{calc_val} "
#            else
#              result << "#{calc_val.abs} "
#            end
#          else
#            if calc_val == 0 then
#
#            elsif calc_val < 0 then
#              result.slice!(-2, 2)
#              result << "\- #{calc_val.to_s.delete("\-")} "
#            else
#              result << "#{calc_val.to_s} "
#            end
#          end
#
#        # tokenが数字ではない場合
#        else
#          if /[a-z]/ =~ token then
#            result_tmp = "#{left_exp}#{token.delete("\-")}"
#            if token.slice(0) == "\-" then
#              if right_exp_list[index - 1] == "\-" then
#                result.slice!(-2, 2)
#                result << "#{result_tmp} "
#              else
#                result << "\-#{result_tmp} "
#              end
#            else
#              result << "#{result_tmp} "
#            end
#          else
#            if !result.empty? then
#              result << "#{token} "
#            end
#          end
#        end
#      }
      result.chop!
      return result
  end

end
