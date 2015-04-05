# coding:utf-8

require './expression.rb'
require 'test/unit'

class RpnTest < Test::Unit::TestCase

  # 入力パターンにおいて、逆ポーランド記法への変換を確認する。
  data(
    'test0' => ['a+4-b+10+c','a 4 + b - 10 + c +'],
    'test1' => ['x+4-(y-30)','x 4 + y 30 - -'],
    'test2' => ['4-x+y-(3+x-y)','4 x - y + 3 x + y - -'],
    'test3' => ['z+x-x+y+y','z x + x - y + y +'],
    'test4' => ['-a-((b-c)-d)-((e-f)-(g-(h-(i-j))))','a - b c - d - - e f - g h i j - - - - -'],
    'test5' => ['(x-x)+(y-y)','x x - y y - +'],
    'test6' => ['123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+a+b+c+d+e-(v+w+x+y+z)+a+b+c+d+e-(v+w+x+y+z)+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+a+b+c+d+e-(v+w+x+y+z)+a+b+c+d+e-(v+w+x+y+z)','123456789 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + a + b + c + d + e + v w + x + y + z + - a + b + c + d + e + v w + x + y + z + - 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + 123456789 + a + b + c + d + e + v w + x + y + z + - a + b + c + d + e + v w + x + y + z + -'],
    'test7' => ['a*b*x+a*b*y','a b * x * a b * y * +'],
    'test8' => ['(x*a+y*b)*(a*b)','x a * y b * + a b * *'],
    'test9' => ['(a+b)*(c+d)*(e+f)','a b + c d + * e f + *'],
  )
  def test_rpn(data)
    exp, rpn_exp = data
    assert_equal(Rpn.get_rpn(exp), rpn_exp)
  end

  # 文字列がInt型の数字であるか確認する。
  data(
    'test1' => '123',
    'test2' => '-5',
  )
  def test_integer_str_true(data)
    str = data
    assert_true(Calculation.integer_string?(str))
  end

  # 文字列が数字でないことを確認する。
  data(
    'test1' => 'abc',
    'test2' => '1+2',
  )
  def test_integer_str_false(data)
    str = data
    assert_false(Calculation.integer_string?(str))
  end

  # 数式から変数のリストに変換する
  def test_exp_2_val_list
    test_exp = "x + y"
    expect = ["x","y"]
    assert_equal(Calculation.exp_2_val_list(test_exp), expect)
    test_exp = "x - y"
    expect = ["x","-y"]
    assert_equal(Calculation.exp_2_val_list(test_exp), expect)
  end

  # 文字列を数字部分と変数部分に分解する
  data(
    'test1' => ['xy', '', 'xy'],
    'test2' => ['x2yz', '', 'x2yz'],
    'test3' => ['3x', '3', 'x'],
    'test4' => ['3x2y', '3', 'x2y'],
  )
  def test_split_num_str(data)
    param, ret_num, ret_str = data
    ret = [ret_num, ret_str]
    assert_equal(Calculation.split_num_str(param), ret)
  end

  # 変数同士の加減算結果を確認する。
  data(
    # 右辺と左辺の変数が異なる場合
    'test1' => ['x', 'y', '+', 'x + y'],
    'test2' => ['xy', '-4y', '+', 'xy - 4y'],
    'test3' => ['-x', '4y', '+', '-x + 4y'],
    'test4' => ['5x', 'y', '+', '5x + y'],
    'test5' => ['5xy', 'x2y', '+', '5xy + x2y'],
    # 右辺と左辺の変数が同じ場合
    'test6' => ['x', 'x', '+', '2x'],
    'test7' => ['3x', '4x', '+', '7x'],
    'test8' => ['-x', '5x', '+', '4x'],
    'test9' => ['-x', 'x', '+', ''],
    'test10' => ['3x', '-3x', '+', ''],
  )
  def test_add_variable(data)
    left_exp, right_exp, calc_type, ret = data
    assert_equal(Calculation.add_sub_variable(left_exp, right_exp, calc_type), ret)
  end

  # 変数を含む多項式の計算結果を確認する。
  #data(
    #'test1' => ['x + 1', 'y', 'x + y + 1'],
    #'test2' => ['x + 1', 'y + 2', 'x + y + 3'],
  #)
  #def test_poloyromial_add(data)
    #left_exp, right_exp, ret = data
    #assert_equal(Calculation.polyromial_add(left_exp, right_exp), ret)
  #end

  # 加算結果を確認する
  data(
    'test1' => ['50', '30', '+', '80'],
    'test2' => ['-10', '20', '+', '10'],
    'test4' => ['0', '0', '+', '0'],
    # 左辺が変数
    'test5' => ['x', '50', '+', 'x + 50'],
    'test6' => ['x - 10', '50', '+', 'x + 40'],
    'test7' => ['x - 30', '30', '+', 'x'],
    'test8' => ['x - 60', '30', '+', 'x - 30'],
    'test9' => ['-x - 60', '30', '+', '-x - 30'],
    'test10' => ['10 + x', '40', '+', '50 + x'],
    'test11' => ['-30 + x', '30', '+', 'x'],
    'test12' => ['-70 - x', '30', '+', '-40 - x'],
    'test13' => ['2x - 3y + 10', '30', '+', '2x - 3y + 40'],
    # 右辺が変数
    'test14' => ['50', 'x', '+', 'x + 50'],
    'test15' => ['50', 'x - 10', '+', 'x + 40'],
    'test16' => ['30', 'x - 30', '+', 'x'],
    'test17' => ['30', 'x - 60', '+', 'x - 30'],
    'test18' => ['30', '-x - 60', '+', '-x - 30'],
    'test19' => ['40', '10 + x', '+', '50 + x'],
    'test20' => ['30', '-30 + x', '+', 'x'],
    'test21' => ['30', '-70 - x', '+', '-40 - x'],
    'test22' => ['30', '2x - 3y + 10', '+', '2x - 3y + 40'],
    # 両辺が変数
    'test23' => ['x', 'y', '+', 'x + y'],
    'test24' => ['-x', 'y', '+', '-x + y'],
    'test25' => ['x', 'x', '+', '2x'],
    'test26' => ['-x', 'x', '+', ''],
    #'test26' => ['2x + 1', 'x', '+', '3x + 1'],
  )
  def test_add(data)
    left_exp, right_exp, calc_type, ret = data
    assert_equal(Calculation.add_sub(left_exp, right_exp, calc_type), ret)
  end

  # 変数同士の減算結果を確認する。
  data(
    # 右辺と左辺の変数が異なる場合
    'test1' => ['x', 'y', '-', 'x - y'],
    'test2' => ['xy', '-4y', '-', 'xy + 4y'],
    'test3' => ['-x', '4y', '-', '-x - 4y'],
    'test4' => ['5x', 'y', '-', '5x - y'],
    'test5' => ['5xy', 'x2y', '-', '5xy - x2y'],
    # 右辺と左辺の変数が同じ場合
    'test6' => ['x', 'x', '-', ''],
    'test7' => ['3x', '4x', '-', '-x'],
    'test8' => ['-x', '5x', '-', '-6x'],
    'test9' => ['-x', 'x', '-', '-2x'],
    'test10' => ['3x', '-3x', '-', '6x'],
    'test11' => ['-2x', '-2x', '-', ''],
  )
  def test_sub_variable(data)
    left_exp, right_exp, calc_type, ret = data
    assert_equal(Calculation.add_sub_variable(left_exp, right_exp, calc_type), ret)
  end


  data(
    'test1' => ['5', '3', '15'],
    'test2' => ['-1', '2', '-2'],
    'test3' => ['0', '0', '0'],
    # 左辺が変数
    'test5' => ['x', '5', '5x'],
#    'test6' => ['x - 1', '5', '5x - 5'],
#    'test7' => ['x - 3', '3', '3x - 9'],
#    'test8' => ['x + 6', '-3', '-3x - 18'],
#    'test9' => ['-x - 6', '3', '-3x - 18'],
#    'test10' => ['1 + x', '4', '4 + 4x'],
#    'test11' => ['-3 + x', '-3', '9 - 3x'],
#    'test11-1' => ['-3 - x', '-3', '9 + 3x'],
#    'test12' => ['-70 - x', '30', '-40 - x'],
#    'test13' => ['2x - 3y + 10', '30', '2x - 3y + 40'],
#    # 右辺が変数
#    'test14' => ['50', 'x', 'x + 50'],
#    'test15' => ['50', 'x - 10', 'x + 40'],
#    'test16' => ['30', 'x - 30', 'x'],
#    'test17' => ['30', 'x - 60', 'x - 30'],
#    'test18' => ['30', '-x - 60', '-x - 30'],
#    'test19' => ['40', '10 + x', '50 + x'],
#    'test20' => ['30', '-30 + x', 'x'],
#    'test21' => ['30', '-70 - x', '-40 - x'],
#    'test22' => ['30', '2x - 3y + 10', '2x - 3y + 40'],
#    # 両辺が変数
#    'test23' => ['x', 'y', 'x + y'],
#    'test24' => ['-x', 'y', '-x + y'],
#    'test25' => ['x', 'x', '2x'],
#    'test26' => ['-x', 'x', ''],
  )
  def test_multipl(data)
    left_exp, right_exp, ret = data
    assert_equal(Calculation.multipl(left_exp, right_exp), ret)
  end
end
