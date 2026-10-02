#include "simulation.hpp"

using namespace cgp;
void simulate(std::vector<particle_structure> &particles, float dt_arg) {

  size_t const N_substep = 1; // Increase this number for faster simulation
                              // (more simulation steps for a given frame)
  float const dt = dt_arg / N_substep;
  for (size_t k_substep = 0; k_substep < N_substep; ++k_substep) {

    vec3 const g = {0, 0, -9.81f};
    size_t const N = particles.size();

    // Update velocity with gravity force and friction
    for (size_t k = 0; k < N; ++k) {
      particle_structure &particle = particles[k];
      vec3 const f = particle.m * g;

      particle.v = (1 - 0.9f * dt) * particle.v + dt * f / particle.m;
    }

    // **************************************** //
    // TO DO: Collision Handling
    //
    // Handle the collision between the spheres and the cube faces.
    //
    //  Hints:
    //    - The cube is by default centered around zero, faces are between
    //    [-1,1]
    //      To compute the intersection between sphere and cube faces, you may
    //      store the normals, and face center positions of the cube in a
    //      vectors.
    //
    //    - Implement and check first the collision between the spheres and the
    //    cube
    //      before the collision between spheres
    //
    // **************************************** //

    // vec3(centers), vec3(normals)
    static std::vector<std::pair<vec3, vec3>> cube = {
        // top
        {vec3(0.0f, 0.0f, 1.0f), vec3(0.0f, 0.0f, -1.0f)},

        // bottom
        {vec3(0.0f, 0.0f, -1.0f), vec3(0.0f, 0.0f, 1.0f)},

        // front
        {vec3(0.0f, 1.0f, 1.0f), vec3(0.0f, -1.0f, 0.0f)},

        // back
        {vec3(0.0f, -1.0f, 1.0f), vec3(0.0f, 1.0f, 0.0f)},

        // right
        {vec3(1.0f, 0.0f, 0.0f), vec3(-1.0f, 0.0f, 0.0f)},

        // left
        {vec3(-1.0f, 0.0f, 1.0f), vec3(1.0f, 0.0f, 0.0f)},
    };

    for (size_t k = 0; k < N; ++k) {
      particle_structure &particle = particles[k];

      // collision with the other particules
      for (size_t i = 0; i < N; ++i) {

        if (i == k)
          continue;

        vec3 p1 = particle.p;
        vec3 p2 = particles[i].p;

        float r1 = particle.r;
        float r2 = particles[i].r;

        float m1 = particle.m;
        float m2 = particles[i].m;

        vec3 v1 = particle.v;
        vec3 v2 = particles[i].v;

        float x = p1.x - p2.x;
        float y = p1.y - p2.y;
        float z = p1.z - p2.z;

        float norm = std::sqrt(x * x + y * y + z * z);

        if (norm <= (r1 + r2)) {
          vec3 u = (p1 - p2) / norm;
          float j = 2 * (m1 * m2) / (m1 + m2) * dot((v2 - v1), u);

          // a. update velocity
          vec3 v1_new, v2_new;

          //   if (m1 == m2) {
          //     v1_new = v1 + ((v2 - v1) * u) * u;
          //     v2_new = v2 - ((v2 - v1) * u) * u;
          //   } else {
          //     v1_new = v1 + j / m1 * u;
          //     v2_new = v2 - j / m2 * u;
          //   }

          v1_new = v1 + j / m1 * u;
          v2_new = v2 - j / m2 * u;

          particle.v = v1_new;
          particles[i].v = v2_new;

          // b. update position
          float d = (r1 + r2) - norm;
          particle.p = p1 + d / 2 * u;
          particles[i].p = p2 - d / 2 * u;
        }
      }

      // check collision with the cube!

      for (const auto [center, normal] : cube) {

        vec3 dir = particle.p - center;
        float detection = dot(dir, normal);

        if (detection <= particle.r) {
          // collision response
          vec3 vper = dot(particle.v, normal) * normal;
          vec3 vpar = particle.v - vper;

          vec3 vnew = 0.9f * vpar - 0.9f * vper;
          particle.v = vnew;

          float d = particle.r - detection;
          particle.p += d * normal;
        }
      }
    }

    // Update position from velocity
    for (size_t k = 0; k < N; ++k) {
      particle_structure &particle = particles[k];
      particle.p = particle.p + dt * particle.v;
    }
  }
}