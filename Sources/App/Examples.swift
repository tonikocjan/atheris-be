//
//  Examples.swift
//  App
//
//  Created by Toni Kocjan on 17/02/2019.
//

import Foundation

public let predefinedSmlExamples = [
  """
val x = 10 + 20;
val y = 10.5 / 2.3;
val z = true andalso 10 < 5;
val a = 5 <= 10 andalso 2.5 >= 3.2;
val b = true = true andalso 5 = 5 andalso "abc" = "efg" andalso 5 * 5 < 13 orelse 3.3 - 2.3 > 0.0;
val c = "123" ^ "456";
val d = ~1;
val e = 5 mod 2;
val f = not true;
""",
  
  """
fun a (x, y, z) a = x ^ y ^ z;
fun b (x, y, z) = x ^ y ^ "abc";
fun c (x, y, z) = x + y + 10;
fun d (x, y, z) = x > 10 andalso true andalso y orelse z;
fun e (x, y, z) = x > 10 andalso true andalso y orelse z;
val v = a ("abc", "efg", "cdf");
""",
  
  """
fun pow (x, y) =
  let
    fun pow (x, y) =
      if y = 0 then 1
      else x * pow (x, y - 1)
  in
    pow (x, y)
  end;
val x = pow (3, 3);
""",
  
  """
fun mul x y z = x * y * z;
val x = mul 10 20 30;
""",
  
  """
val x = {a = 10, b = "string", promise = {evaled = false, f = fn x => x * x}};
val a = (#f (#promise x)) (10);
""",
  
  """
datatype prevozno_sredstvo_t =
  Bus of int
  | Avto of (string*string*int)
  | Pes;

val x = Bus 10;
val y = Avto ("abc", "efg", 10);
val z = Pes;
val a = x::[y, z];
""",
  
  """
datatype natural = NEXT of natural | ZERO;

fun toInt (a) =
  case a of
    ZERO => 0
    | NEXT i => 1 + toInt(i);

val x = NEXT(ZERO);
val a = toInt x;
""",
  
  """
val x = [2, 3, 4, 5];
case x of
  [] => 1
  | 2::3::h3::t => 2
  | h1::5::t => 3
  | h::t => 4;

val xs = [true, true, true, false];
case xs of
  true::true::true::[] => 1
  | true::true::true::tl => 2
  | false::tl => 3;
""",
  
  """
datatype ('a, 'b) X = A of ('a * int) | B of ('b * string);
val x: (int, bool) X = A (10, 20);
val y: (int, bool) X = B (true, "rocket");
""",
]
