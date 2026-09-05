import axios from "https://cdn.jsdelivr.net/npm/axios@1.19.0/+esm";

const api = axios.create({
    baseURL: "http://localhost:5227"
});

export default api;