// Borrows algorithm from MIT-licensed pendulum code:
//    https://github.com/openai/gym/blob/master/gym/envs/classic_control/pendulum.py
// By Carlos Luis

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>

#ifdef _WIN32
#   define MODULE_API __declspec(dllexport)
#else
#   define MODULE_API
#endif


const double max_speed = 8.0;
const double max_torque = 2.0;
const double dt = 0.05;
const double g = 9.8;
const double m = 1.0;
const double l = 1.0;

double last_torque = 0.0;
double theta = 0.0;
double theta_dt = 0.0;

MODULE_API void instantiate(char *setup_txt) {
	(void)setup_txt;
	srand(time(0));
}

MODULE_API void reset() {
	double r = (double)rand();
	r = r * 2.0 / (double)RAND_MAX;
	r -= 1.0;
	theta = r * M_PI;

	double r2 = (double)rand();
	theta_dt = (r2 * 2.0 / (double)RAND_MAX) - 1.0;
}

MODULE_API int step(double *action, int n_actions) {
	(void)n_actions;
	last_torque = action[0];
	if(last_torque > max_torque) last_torque = max_torque;
	if(last_torque < -max_torque) last_torque = -max_torque;

	theta_dt = theta_dt + (3 * g / (2 * l) * sin(theta) + 3.0 / (m * l*l) * last_torque) * dt;
	if(theta_dt > max_speed) theta_dt = max_speed;
	if(theta_dt < -max_speed) theta_dt = -max_speed;
	theta = theta + dt * theta_dt;

	while(theta < -M_PI) {
		theta += 2.0 * M_PI;
	}
	while(theta > M_PI) {
		theta -= 2.0 * M_PI;
	}

	return 0;
}

MODULE_API void render() {
	printf("theta=%f, theta_dt=%f\n", theta, theta_dt);
}

MODULE_API double reward() {
	return theta*theta + 0.1 * theta_dt * theta_dt + 0.001 * last_torque;
}

MODULE_API int get_rl_obs(double *to_populate, int length) {
	(void)length;
	to_populate[0] = l * cos(theta);
	to_populate[1] = l * sin(theta);
	to_populate[2] = theta_dt;
	return 3;
}

MODULE_API int get_action_space(double act_low[], double act_high[], int len) {
	(void)len;
	if(NULL != act_low && NULL != act_high) {
		act_low[0] = -max_torque;
		act_high[0] = max_torque;
	}
	return 1;
}

MODULE_API int get_action_len() {
	int len = get_action_space(NULL, NULL, 0);
	return len;
}

MODULE_API int get_observation_space(double obs_low[], double obs_high[], int len) {
	(void)len;
	if(NULL != obs_low && NULL != obs_high) {
		obs_low[0] = -l;
		obs_high[0] = l;
		obs_low[1] = -l;
		obs_high[1] = l;
		obs_low[2] = -max_speed;
		obs_high[2] = max_speed;
	}
	return 3;
}

MODULE_API int get_observation_len() {
	return get_observation_space(NULL, NULL, 0);
}

