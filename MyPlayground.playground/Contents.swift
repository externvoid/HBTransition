//: Playground - noun: a place where people can play

import UIKit

let color = UIColor.red
var r:CGFloat = 0.0, g:CGFloat = 0.0, b:CGFloat = 0.0, a:CGFloat = 0.0
color.getRed(&r, green:&g, blue:&b, alpha:&a)
print(r, g, b, a)

//UIColor *color = [UIColor redColor];
//CGFloat r, g, b, a;
//const CGFloat *components = CGColorGetComponents(color.CGColor);
//if (CGColorGetNumberOfComponents(color.CGColor) == 4)　{
//  r = components[0];
//  g = components[1];
//  b = components[2];
//  a = components[3];
//} else {
//  r = components[0];
//  g = components[0];
//  b = components[0];
//  a = components[1];
//}