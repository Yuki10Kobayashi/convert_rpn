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

  # 加算結果を確認する
  data(
    'test1' => ['50', '30', '80'],
    'test2' => ['-10', '20', '10'],
    'test4' => ['0', '0', '0'],
    # 左辺が変数
    'test5' => ['x', '50', 'x + 50'],
    'test6' => ['x - 10', '50', 'x + 40'],
    'test7' => ['x - 30', '30', 'x'],
    'test8' => ['x - 60', '30', 'x - 30'],
    'test9' => ['-x - 60', '30', '-x - 30'],
    'test10' => ['10 + x', '40', '50 + x'],
    'test11' => ['-30 + x', '30', 'x'],
    'test12' => ['-70 - x', '30', '-40 - x'],
    'test13' => ['2x - 3y + 10', '30', '2x - 3y + 40'],
    # 右辺が変数
    'test14' => ['50', 'x', 'x + 50'],
    'test15' => ['50', 'x - 10', 'x + 40'],

    # 両辺が変数
  )
  def test_add(data)
    left_exp, right_exp, ret = data
    assert_equal(Calculation.add(left_exp, right_exp), ret)
  end
end
