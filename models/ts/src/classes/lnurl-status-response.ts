export class LnurlStatusResponse {
	constructor(public status: 'ERROR' | 'OK', public reason?: string | null) {}
}
