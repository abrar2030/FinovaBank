/**
 * Tests for the FinovaBank mobile API layer and configuration.
 *
 * The repository shipped with no tests for the mobile app. These lock in the
 * request paths and the configuration defaults so contract drift (paths,
 * base URL, timeout) is caught.
 */
import axios from "axios";

// Mock axios so the api client's methods are spies and no real requests run.
jest.mock("axios", () => {
  const client = {
    get: jest.fn(() => Promise.resolve({ data: {} })),
    post: jest.fn(() => Promise.resolve({ data: {} })),
    put: jest.fn(() => Promise.resolve({ data: {} })),
    delete: jest.fn(() => Promise.resolve({ data: {} })),
    interceptors: {
      request: { use: jest.fn() },
      response: { use: jest.fn() },
    },
  };
  return { __esModule: true, default: { create: jest.fn(() => client) } };
});

import * as api from "../api";
import Config from "../config";

const client = (axios.create as jest.Mock).mock.results[0].value;

beforeEach(() => {
  client.get.mockClear();
  client.post.mockClear();
  client.put.mockClear();
  client.delete.mockClear();
});

describe("config", () => {
  it("provides a default API base URL and timeout", () => {
    expect(typeof Config.API_BASE_URL).toBe("string");
    expect(Config.API_BASE_URL.length).toBeGreaterThan(0);
    expect(Config.API_TIMEOUT).toBeGreaterThan(0);
  });
});

describe("account endpoints", () => {
  it("getUserAccounts -> GET /accounts", () => {
    api.getUserAccounts();
    expect(client.get).toHaveBeenCalledWith("/accounts");
  });

  it("getAccountDetails -> GET /accounts/:id", () => {
    api.getAccountDetails("ACC1");
    expect(client.get).toHaveBeenCalledWith("/accounts/ACC1");
  });

  it("createAccount -> POST /accounts", () => {
    api.createAccount({ accountType: "CHECKING" });
    expect(client.post).toHaveBeenCalledWith("/accounts", {
      accountType: "CHECKING",
    });
  });
});

describe("transaction endpoints", () => {
  it("createTransaction -> POST /transactions", () => {
    api.createTransaction({ amount: 10 });
    expect(client.post).toHaveBeenCalledWith("/transactions", { amount: 10 });
  });

  it("getAccountTransactions -> nested account path with params", () => {
    api.getAccountTransactions("ACC1", { limit: 5 });
    expect(client.get).toHaveBeenCalledWith("/accounts/ACC1/transactions", {
      params: { limit: 5 },
    });
  });
});

describe("auth endpoints", () => {
  it("loginUser -> POST /auth/login with credentials", () => {
    api.loginUser({ email: "a@b.com", password: "pw" });
    expect(client.post).toHaveBeenCalledWith("/auth/login", {
      email: "a@b.com",
      password: "pw",
    });
  });

  it("registerUser -> POST /auth/register", () => {
    const payload = {
      firstName: "A",
      lastName: "B",
      email: "a@b.com",
      password: "pw",
    };
    api.registerUser(payload);
    expect(client.post).toHaveBeenCalledWith("/auth/register", payload);
  });
});

describe("savings endpoints", () => {
  it("deleteSavingsGoal -> DELETE /savings/:id", () => {
    api.deleteSavingsGoal("G1");
    expect(client.delete).toHaveBeenCalledWith("/savings/G1");
  });
});
