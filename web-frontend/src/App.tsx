import React from "react";
import { Routes, Route } from "react-router-dom";
import { Box } from "@mui/material";
import Dashboard from "./pages/Dashboard";
import Login from "./pages/Login";
import Register from "./pages/Register";
import AccountDetails from "./pages/AccountDetails";
import Transactions from "./pages/Transactions";
import Loans from "./pages/Loans";
import SavingsGoals from "./pages/SavingsGoals";
import Layout from "./components/Layout";
import ProtectedRoute from "./components/ProtectedRoute";
import { AuthProvider } from "./context/AuthContext";

function App() {
  return (
    <AuthProvider>
      <Box
        sx={{ display: "flex", flexDirection: "column", minHeight: "100vh" }}
      >
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<Dashboard />} />
            <Route path="accounts/:accountId" element={<AccountDetails />} />
            <Route path="transactions" element={<Transactions />} />
            <Route path="loans" element={<Loans />} />
            <Route path="savings" element={<SavingsGoals />} />
          </Route>
        </Routes>
      </Box>
    </AuthProvider>
  );
}

export default App;
