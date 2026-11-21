# Lab 6: Build a Network-Driven Directory

## Public Test API Endpoint (R1)

- Endpoint: `https://jsonplaceholder.typicode.com/users`
- HTTP Method: `GET`
- Query Parameter Support: `_limit` via `URLComponents`

## Test Cases (R5 & Submission Requirement)

| Test Case | Input / Mock Condition | Expected Outcome | Actual Outcome |
| :--- | :--- | :--- | :--- |
| 1. Valid JSON Payload | HTTP 200 + valid user JSON array | Decodes `[DirectoryPerson]` and displays list + detail view | Passed (`Leanne Graham` decoded) |
| 2. Invalid URL | Malformed endpoint string (`"not a valid url"`) | Throws `DirectoryAPIError.invalidURL` | Passed |
| 3. Non-Success HTTP Status | HTTP 500 Internal Server Error | Throws `DirectoryAPIError.httpFailure(statusCode: 500)` and shows Retry | Passed |
| 4. Decoding Failure | HTTP 200 + corrupt JSON (`"{bad_json}"`) | Throws `DirectoryAPIError.decodingFailed` | Passed |
| 5. Empty Result Set | HTTP 200 + empty array (`"[]"`) | Throws `DirectoryAPIError.emptyDirectory` | Passed |
| 6. Network Failure | Offline / `URLError(.notConnectedToInternet)` | Throws `DirectoryAPIError.networkFailure` and shows Retry | Passed |

## Extension: Search & Avoiding Excessive Network Requests

- Local Search Filtering: Once `DirectoryAPIService.fetchDirectory()` loads the directory, `.searchable` filters `filteredPeople` in memory without triggering extra network calls on every keystroke.
- Remote Search Rate-Limiting Strategy: If search queries were sent to a server endpoint per keystroke, we would debounce input by waiting 300–400 ms (`try await Task.sleep(nanoseconds: 350_000_000)`) inside a cancellable `.task(id: searchQuery)` modifier so in-flight requests cancel automatically whenever the user types another character.
