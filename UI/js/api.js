import axios from "https://cdn.jsdelivr.net/npm/axios@1.19.0/+esm";

const api = axios.create({
    baseURL: "https://localhost:5001"
});

export default api;