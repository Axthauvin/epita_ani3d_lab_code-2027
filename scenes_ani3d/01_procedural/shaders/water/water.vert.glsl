#version 330 core

// Vertex shader - this code is executed for every vertex of the shape

// Inputs coming from VBOs
layout(location = 0) in vec3
    vertex_position; // vertex position in local space (x,y,z)
layout(location = 1) in vec3
    vertex_normal; // vertex normal in local space   (nx,ny,nz)
layout(location = 2) in vec3 vertex_color; // vertex color      (r,g,b)
layout(location = 3) in vec2 vertex_uv;    // vertex uv-texture (u,v)

// Output variables sent to the fragment shader
out struct fragment_data {
  vec3 position; // vertex position in world space
  vec3 normal;   // normal position in world space
  vec3 color;    // vertex color
  vec2 uv;       // vertex uv
} fragment;

// Uniform variables expected to receive from the C++ program
uniform mat4
    model; // Model affine transform matrix associated to the current shape
uniform mat4 view; // View matrix (rigid transform) of the camera
uniform mat4
    projection; // Projection (perspective or orthogonal) matrix of the camera

uniform float time; // Time in seconds since the start of the program

// Simplex noise functions
float snoise(in vec2 v, int octaves);
float snoise_abs(in vec2 v, int octaves);
float snoise(in vec3 v, int octaves);
float snoise_abs(in vec3 v, int octaves);

float deformation(float x, float z, float t) {

  // TO DO: Modifiy this function to compute the height field deformation on top
  // of the flat surface
  //  The surface is computed as (x,y,z) = (x, deformation(x,y,t), z)
  //  ...

  // float y_out = 0.0; // return currently y=0 => flat surface
  float y_out = 0.06f * sin(2 * t - 10 * sqrt(x * x + z * z)) +
                0.04f * snoise(vec2(x, z), 2) - 0.02f;

  return y_out;
}

// Evaluate the normals numerically assuming the function is a heightfield
// f(x,y)=(x,y,h(x,y))
vec4 evaluate_normal(float x, float z, float t) {
  float e = 0.005; // a small value to compute the numerical differentiation
  float dhdu =
      (deformation(x + e, z, t) - deformation(x - e, z, t)) / (1.0 * e);
  float dhdv =
      (deformation(x, z + e, t) - deformation(x, z - e, t)) / (1.0 * e);

  return normalize(vec4(-dhdu, 1.0, -dhdv, 0.0));
}

void main() {
  // The position of the vertex in the world space
  vec4 position = model * vec4(vertex_position, 1.0);

  position.y = position.y + deformation(position.x, position.z, time);

  // The normal of the vertex in the world space
  mat4 modelNormal = transpose(inverse(model));
  vec4 normal = modelNormal * evaluate_normal(position.x, position.z, time);

  // The projected position of the vertex in the normalized device coordinates:
  vec4 position_projected = projection * view * position;

  // Fill the parameters sent to the fragment shader
  fragment.position = position.xyz;
  fragment.normal = normal.xyz;
  fragment.color = vertex_color;
  fragment.uv = vertex_uv;

  // gl_Position is a built-in variable which is the expected output of the
  // vertex shader
  gl_Position =
      position_projected; // gl_Position is the projected vertex position (in
                          // normalized device coordinates)
}

// ************************************************ //
// GLSL Simplex Noise
// //
// Description : Array and textureless GLSL 2D/3D/4D simplex
// noise functions.
// Author : Ian McEwan, Ashima Arts.
// Maintainer : ijm
// Lastmod : 20110822 (ijm)
// License : Copyright (C) 2011 Ashima Arts. All rights reserved.
// Distributed under the MIT License. See LICENSE file.
// https://github.com/ashima/webgl-noise
//
// See: https://www.shadertoy.com/view/Mds3Wr
// ************************************************ //
float smooth_snoise(in vec2 v);
float smooth_snoise(in vec3 v);
float snoise(in vec2 v, int octaves) {
  float res = 0.0;
  float scale = 1.0;
  for (int i = 0; i < 8; i++) {
    if (i >= octaves)
      break;
    res += smooth_snoise(v) * scale;
    v *= vec2(2.0, 2.0);
    scale *= 0.5;
  }
  return res;
}
float snoise(in vec3 v, int octaves) {
  float res = 0.0;
  float scale = 1.0;
  for (int i = 0; i < 8; i++) {
    if (i >= octaves)
      break;
    res += smooth_snoise(v) * scale;
    v *= vec3(2.0, 2.0, 2.0);
    scale *= 0.5;
  }
  return res;
}
float snoise_abs(in vec2 v, int octaves) {
  float res = 0.0;
  float scale = 1.0;
  for (int i = 0; i < 8; i++) {
    if (i >= octaves)
      break;
    res += abs(smooth_snoise(v)) * scale;
    v *= vec2(2.0, 2.0);
    scale *= 0.5;
  }
  return res;
}
float snoise_abs(in vec3 v, int octaves) {
  float res = 0.0;
  float scale = 1.0;
  for (int i = 0; i < 8; i++) {
    if (i >= octaves)
      break;
    res += abs(smooth_snoise(v)) * scale;
    v *= vec3(2.0, 2.0, 2.0);
    scale *= 0.5;
  }
  return res;
}
vec3 mod289(in vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(in vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(in vec3 x) { return mod289(((x * 34.0) + 1.0) * x); }
float smooth_snoise(in vec2 v) {
  const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626,
                      0.024390243902439);
  // First corner
  vec2 i = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);

  // Other corners
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  // Permutations
  i = mod289(i);
  vec3 p =
      permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));

  vec3 m = max(
      0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
  m = m * m;
  m = m * m;

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

  vec3 g;
  g.x = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

vec4 mod289(in vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 permute(in vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }

vec4 taylorInvSqrt(in vec4 r) {
  return 1.79284291400159 - 0.85373472095314 * r;
}

float smooth_snoise(in vec3 v) {
  const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
  const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

  // First corner
  vec3 i = floor(v + dot(v, C.yyy));
  vec3 x0 = v - i + dot(i, C.xxx);

  // Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min(g.xyz, l.zxy);
  vec3 i2 = max(g.xyz, l.zxy);

  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy;
  vec3 x3 = x0 - D.yyy;

  // Permutations
  i = mod289(i);
  vec4 p = permute(permute(permute(i.z + vec4(0.0, i1.z, i2.z, 1.0)) + i.y +
                           vec4(0.0, i1.y, i2.y, 1.0)) +
                   i.x + vec4(0.0, i1.x, i2.x, 1.0));
  float n_ = 0.142857142857;
  vec3 ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_);

  vec4 x = x_ * ns.x + ns.yyyy;
  vec4 y = y_ * ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4(x.xy, y.xy);
  vec4 b1 = vec4(x.zw, y.zw);

  vec4 s0 = floor(b0) * 2.0 + 1.0;
  vec4 s1 = floor(b1) * 2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
  vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

  vec3 p0 = vec3(a0.xy, h.x);
  vec3 p1 = vec3(a0.zw, h.y);
  vec3 p2 = vec3(a1.xy, h.z);
  vec3 p3 = vec3(a1.zw, h.w);

  vec4 norm =
      taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

  vec4 m =
      max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
  m = m * m;
  return 42.0 *
         dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}
// ************************************************ //