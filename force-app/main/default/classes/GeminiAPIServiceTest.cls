@isTest
private class GeminiAPIServiceTest {

    // Mock for a successful response
    private class GeminiSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            res.setBody(JSON.serialize(new Map<String, Object>{
                'candidates' => new List<Object>{
                    new Map<String, Object>{
                        'content' => new Map<String, Object>{
                            'parts' => new List<Object>{
                                new Map<String, Object>{ 'text' => 'This is a generated resolution.' }
                            }
                        }
                    }
                }
            }));

            return res;
        }
    }

    // Mock for a failed response (e.g. 500)
    private class GeminiErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            res.setBody('{"error": "Something went wrong"}');
            return res;
        }
    }

    // Mock for a malformed response (no candidates)
    private class GeminiMalformedMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{}'); // No 'candidates' key
            return res;
        }
    }

    @isTest
    static void testSuccessfulGeminiCallout() {
        Test.setMock(HttpCalloutMock.class, new GeminiSuccessMock());

        Test.startTest();
        GeminiAPIService.GeminiResponse result = GeminiAPIService.generateContent('Test prompt');
        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals('This is a generated resolution.', result.generatedText);
        System.assertEquals(null, result.errorMessage);
    }

    @isTest
    static void testFailedGeminiCallout() {
        Test.setMock(HttpCalloutMock.class, new GeminiErrorMock());

        Test.startTest();
        GeminiAPIService.GeminiResponse result = GeminiAPIService.generateContent('Test prompt');
        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals(null, result.generatedText);
        System.assert(result.errorMessage.contains('Gemini call failed'), 'Expected error message to contain failure reason');
    }

    @isTest
    static void testMalformedGeminiCallout() {
        Test.setMock(HttpCalloutMock.class, new GeminiMalformedMock());

        Test.startTest();
        GeminiAPIService.GeminiResponse result = GeminiAPIService.generateContent('Test prompt');
        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals(null, result.generatedText);
        System.assertEquals('No response from Gemini.', result.errorMessage);
    }
}