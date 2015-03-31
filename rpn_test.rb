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

  data(
    'test1' => '123',
    'test4' => '-5',
  )
  def test_integer_str_true(data)
    str = data
    assert_true(Calculation.integer_string?(str))
  end                

  data(
    'test2' => 'abc',
    'test3' => '1+2',
  )
  def test_integer_str_false(data)
    str = data
    assert_false(Calculation.integer_string?(str))
  end                
end
