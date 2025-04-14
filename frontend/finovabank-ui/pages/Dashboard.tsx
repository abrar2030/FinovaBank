import React, { useState, useEffect } from 'react';
import { 
  Box, 
  Typography, 
  Card, 
  CardContent, 
  CardHeader,
  Button,
  Divider,
  Avatar,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  CircularProgress,
  Alert,
  useTheme
} from '@mui/material';
import { 
  AccountBalance as AccountIcon,
  TrendingUp as TrendingUpIcon,
  CreditCard as CreditCardIcon,
  Savings as SavingsIcon,
  ArrowUpward as ArrowUpwardIcon,
  ArrowDownward as ArrowDownwardIcon
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { accountAPI, transactionAPI, savingsAPI } from '../services/api';
import { Chart as ChartJS, ArcElement, Tooltip, Legend, CategoryScale, LinearScale, PointElement, LineElement, Title } from 'chart.js';
import { Doughnut, Line } from 'react-chartjs-2';

// Register ChartJS components
ChartJS.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, PointElement, LineElement, Title);

const Dashboard: React.FC = () => {
  const { user } = useAuth();
  const theme = useTheme();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [accountData, setAccountData] = useState({
    balance: 0,
    accountNumber: '',
    accountType: ''
  });
  const [recentTransactions, setRecentTransactions] = useState([]);
  const [savingsGoals, setSavingsGoals] = useState([]);

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        // Fetch accounts
        const accountsResponse = await accountAPI.getAccounts();
        if (accountsResponse.data && accountsResponse.data.length > 0) {
          const account = accountsResponse.data[0]; // Get first account
          setAccountData({
            balance: account.balance,
            accountNumber: `****${account.accountId.toString().slice(-4)}`,
            accountType: account.accountType
          });
        }
        
        // Fetch recent transactions
        const transactionsResponse = await transactionAPI.getTransactions({ limit: 4 });
        setRecentTransactions(transactionsResponse.data || []);
        
        // Fetch savings goals
        const savingsResponse = await savingsAPI.getSavingsGoals();
        setSavingsGoals(savingsResponse.data || []);
        
      } catch (err) {
        console.error('Error fetching dashboard data:', err);
        setError('Failed to load dashboard data. Please try again later.');
      } finally {
        setLoading(false);
      }
    };
    
    fetchDashboardData();
  }, []);

  // Spending breakdown chart data
  const spendingData = {
    labels: ['Housing', 'Food', 'Transportation', 'Entertainment', 'Utilities'],
    datasets: [
      {
        data: [35, 25, 15, 15, 10],
        backgroundColor: [
          theme.palette.primary.main,
          theme.palette.secondary.main,
          theme.palette.success.main,
          theme.palette.warning.main,
          theme.palette.info.main,
        ],
        borderWidth: 1,
      },
    ],
  };

  // Monthly balance chart data
  const balanceData = {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    datasets: [
      {
        label: 'Balance',
        data: [9500, 10200, 11000, 10800, 11500, 12500],
        borderColor: theme.palette.primary.main,
        backgroundColor: theme.palette.primary.main + '20',
        tension: 0.3,
        fill: true,
      },
    ],
  };

  const balanceOptions = {
    responsive: true,
    plugins: {
      legend: {
        display: false,
      },
      title: {
        display: false,
      },
    },
    scales: {
      y: {
        beginAtZero: false,
      },
    },
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return (
      <Box sx={{ mt: 4 }}>
        <Alert severity="error">{error}</Alert>
        <Button 
          variant="contained" 
          sx={{ mt: 2 }}
          onClick={() => window.location.reload()}
        >
          Retry
        </Button>
      </Box>
    );
  }

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 4, fontWeight: 'bold' }}>
        Welcome back, {user?.name}
      </Typography>
      
      <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr', lg: '1fr 1fr 1fr' }, gap: 3 }}>
        {/* Account Summary Card */}
        <Card elevation={0} sx={{ height: '100%', borderRadius: 3, border: `1px solid ${theme.palette.divider}` }}>
          <CardHeader 
            title="Account Summary" 
            titleTypographyProps={{ variant: 'h6', fontWeight: 'bold' }}
          />
          <CardContent>
            <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
              <Avatar sx={{ bgcolor: theme.palette.primary.main, mr: 2 }}>
                <AccountIcon />
              </Avatar>
              <Box>
                <Typography variant="body2" color="text.secondary">
                  {accountData.accountType} Account
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {accountData.accountNumber}
                </Typography>
              </Box>
            </Box>
            <Typography variant="h4" sx={{ fontWeight: 'bold', mb: 2 }}>
              ${accountData.balance.toLocaleString('en-US', { minimumFractionDigits: 2 })}
            </Typography>
            <Button 
              variant="contained" 
              fullWidth
              onClick={() => navigate('/transactions')}
            >
              Transfer Money
            </Button>
          </CardContent>
        </Card>

        {/* Spending Breakdown Card */}
        <Card elevation={0} sx={{ height: '100%', borderRadius: 3, border: `1px solid ${theme.palette.divider}` }}>
          <CardHeader 
            title="Spending Breakdown" 
            titleTypographyProps={{ variant: 'h6', fontWeight: 'bold' }}
          />
          <CardContent>
            <Box sx={{ height: 200, display: 'flex', justifyContent: 'center' }}>
              <Doughnut data={spendingData} />
            </Box>
          </CardContent>
        </Card>

        {/* Quick Actions Card */}
        <Card elevation={0} sx={{ height: '100%', borderRadius: 3, border: `1px solid ${theme.palette.divider}` }}>
          <CardHeader 
            title="Quick Actions" 
            titleTypographyProps={{ variant: 'h6', fontWeight: 'bold' }}
          />
          <CardContent>
            <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 2 }}>
              <Button 
                variant="outlined" 
                fullWidth 
                startIcon={<TrendingUpIcon />}
                sx={{ justifyContent: 'flex-start', py: 1.5 }}
                onClick={() => navigate('/transactions')}
              >
                Pay Bills
              </Button>
              <Button 
                variant="outlined" 
                fullWidth 
                startIcon={<CreditCardIcon />}
                sx={{ justifyContent: 'flex-start', py: 1.5 }}
                onClick={() => navigate('/loans')}
              >
                New Loan
              </Button>
              <Button 
                variant="outlined" 
                fullWidth 
                startIcon={<SavingsIcon />}
                sx={{ justifyContent: 'flex-start', py: 1.5 }}
                onClick={() => navigate('/savings')}
              >
                New Goal
              </Button>
              <Button 
                variant="outlined" 
                fullWidth 
                startIcon={<AccountIcon />}
                sx={{ justifyContent: 'flex-start', py: 1.5 }}
                onClick={() => navigate('/accounts/1')}
              >
                Statements
              </Button>
            </Box>
          </CardContent>
        </Card>
      </Box>

      <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '2fr 1fr' }, gap: 3, mt: 3 }}>
        {/* Recent Transactions Card */}
        <Card elevation={0} sx={{ borderRadius: 3, border: `1px solid ${theme.palette.divider}` }}>
          <CardHeader 
            title="Recent Transactions" 
            titleTypographyProps={{ variant: 'h6', fontWeight: 'bold' }}
            action={
              <Button 
                color="primary"
                onClick={() => navigate('/transactions')}
              >
                View All
              </Button>
            }
          />
          <Divider />
          <CardContent sx={{ p: 0 }}>
            {recentTransactions.length > 0 ? (
              <List>
                {recentTransactions.map((transaction: any) => (
                  <React.Fragment key={transaction.transactionId}>
                    <ListItem sx={{ py: 2 }}>
                      <ListItemIcon>
                        <Avatar 
                          sx={{ 
                            bgcolor: transaction.transactionType === 'CREDIT' 
                              ? theme.palette.success.light 
                              : theme.palette.error.light 
                          }}
                        >
                          {transaction.transactionType === 'CREDIT' 
                            ? <ArrowUpwardIcon sx={{ color: theme.palette.success.dark }} /> 
                            : <ArrowDownwardIcon sx={{ color: theme.palette.error.dark }} />}
                        </Avatar>
                      </ListItemIcon>
                      <ListItemText 
                        primary={transaction.description || `Transaction #${transaction.transactionId}`}
                        secondary={new Date(transaction.date).toLocaleDateString()}
                      />
                      <Typography 
                        variant="body1" 
                        sx={{ 
                          fontWeight: 'bold',
                          color: transaction.transactionType === 'CREDIT' 
                            ? theme.palette.success.main 
                            : theme.palette.error.main
                        }}
                      >
                        {transaction.transactionType === 'CREDIT' ? '+' : ''}
                        ${Math.abs(transaction.amount).toLocaleString('en-US', { minimumFractionDigits: 2 })}
                      </Typography>
                    </ListItem>
                    <Divider component="li" />
                  </React.Fragment>
                ))}
              </List>
            ) : (
              <Box sx={{ p: 3, textAlign: 'center' }}>
                <Typography variant="body1" color="text.secondary">
                  No recent transactions found.
                </Typography>
              </Box>
            )}
          </CardContent>
        </Card>

        {/* Savings Goals Card */}
        <Card elevation={0} sx={{ borderRadius: 3, border: `1px solid ${theme.palette.divider}` }}>
          <CardHeader 
            title="Savings Goals" 
            titleTypographyProps={{ variant: 'h6', fontWeight: 'bold' }}
            action={
              <Button 
                color="primary"
                onClick={() => navigate('/savings')}
              >
                Add Goal
              </Button>
            }
          />
          <Divider />
          <CardContent>
            {savingsGoals.length > 0 ? (
              savingsGoals.map((goal: any) => {
                const progress = Math.min(100, Math.round((goal.currentAmount / goal.targetAmount) * 100));
                
                return (
                  <Box key={goal.goalId} sx={{ mb: 3 }}>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
                      <Typography variant="body1" fontWeight="medium">{goal.goalName}</Typography>
                      <Typography variant="body2" color="text.secondary">
                        ${goal.currentAmount.toLocaleString()} / ${goal.targetAmount.toLocaleString()}
                      </Typography>
                    </Box>
                    <Box sx={{ width: '100%', bgcolor: theme.palette.grey[200], borderRadius: 5, height: 10 }}>
                      <Box
                        sx={{
                          width: `${progress}%`,
                          bgcolor: theme.palette.primary.main,
                          borderRadius: 5,
                          height: 10,
                        }}
                      />
                    </Box>
                  </Box>
                );
              })
            ) : (
              <Box sx={{ textAlign: 'center', py: 2 }}>
                <Typography variant="body1" color="text.secondary">
                  No savings goals found.
                </Typography>
                <Button 
                  variant="outlined" 
                  sx={{ mt: 2 }}
                  onClick={() => navigate('/savings')}
                >
                  Create Your First Goal
                </Button>
              </Box>
            )}
          </CardContent>
        </Card>
      </Box>

      {/* Monthly Balance Chart */}
      <Box sx={{ mt: 3 }}>
        <Card elevation={0} sx={{ borderRadius: 3, border: `1px solid ${theme.palette.divider}` }}>
          <CardHeader 
            title="Balance History" 
            titleTypographyProps={{ variant: 'h6', fontWeight: 'bold' }}
          />
          <CardContent>
            <Box sx={{ height: 300 }}>
              <Line options={balanceOptions} data={balanceData} />
            </Box>
          </CardContent>
        </Card>
      </Box>
    </Box>
  );
};

export default Dashboard;
