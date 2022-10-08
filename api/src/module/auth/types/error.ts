export class AuthError extends Error {
	message = 'authentication details incorrect';
	statusCode = 401;
}
