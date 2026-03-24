const request = require('supertest');
const app = require('./index');

describe('GET /api/health', () => {
    it('returns status ok', async () => {
        const res = await request(app).get('/api/health');
        expect(res.statusCode).toBe(200);
        expect(res.body.status).toBe('ok');
    });
});

describe('POST /api/items', () => {
    it('rejects empty name', async () => {
        const res = await request(app).post('/api/items').send({ name: '' });
        expect(res.statusCode).toBe(400);
    });
});
