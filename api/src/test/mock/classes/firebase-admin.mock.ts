export const MockFirebaseAdmin = {
	auth: () => ({}),
	messaging: () => ({
		send: async (info) => info,
	}),
};
