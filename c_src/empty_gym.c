#include <stdio.h>
#include <stdlib.h>

#ifdef _WIN32
#   define MODULE_API __declspec(dllexport)
#else
#   define MODULE_API
#endif

MODULE_API void instantiate(char *setup_txt) {
	printf("In Instantiate. setup_txt=%s\n", setup_txt);
}

MODULE_API void reset() {
	printf("In reset.\n");
}

MODULE_API int step(double *action, int n_actions) {
	(void)action;
	printf("In step. n_actions=%d\n", n_actions);
	return 0;
}

MODULE_API void render() {
	printf("In render.\n");
}

MODULE_API double reward() {
	printf("In reward.\n");
	return 0.98;
}

MODULE_API int get_rl_obs(double *to_populate, int length) {
	printf("In get_rl_obs. length=%d\n", length);
	to_populate[0] = 0.0;
	to_populate[1] = 2.718;
	to_populate[2] = 42;
	return length;
}

MODULE_API int get_action_space(double act_low[], double act_high[], int len) {
	printf("In get_action_space. length=%d\n", len);
	if(NULL != act_low && NULL != act_high) {
		act_low[0] = -1.0;
		act_high[0] = 1.0;
	}
	return 1;
}

MODULE_API int get_action_len() {
	printf("In get_action_len\n");
	int len = get_action_space(NULL, NULL, 0);
	return len;
}

MODULE_API int get_observation_space(double obs_low[], double obs_high[], int len) {
	printf("In get_observation_space. length=%d\n", len);
	if(NULL != obs_low && NULL != obs_high) {
		obs_low[0] = -1.0;
		obs_high[0] = 1.0;
		obs_low[1] = 0.0;
		obs_high[1] = 10.0;
		obs_low[2] = -42.0;
		obs_high[2] = 42.0;
	}
	return 3;
}

MODULE_API int get_observation_len() {
	printf("In get_observation_len\n");
	return get_observation_space(NULL, NULL, 0);
}

