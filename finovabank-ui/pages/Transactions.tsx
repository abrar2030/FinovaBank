import React, { useState, useEffect } from 'react';
import { 
  Box, 
  Typography, 
  Card, 
  CardContent, 
  CardHeader,
  Button,
  Divider,
  TextField,
  MenuItem,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  CircularProgress,
  Alert,
  useTheme
} from '@mui/material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDateFns as DateFnsAdapter } from '@mui/x-date-pickers/AdapterDateFns';
import { transactionAPI } from '../services/api';

const Transactions: React.FC = () => {
  const theme = useTheme();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [transactions, setTransactions] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [transactionType, setTransactionType] = useState('ALL');
  const [startDate, setStartDate] = useState<Date | null>(null);
  const [endDate, setEndDate] = useState<Date | null>(null);

  useEffect(() => {
    const fetchTransactions = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const response = await transactionAPI.getTransactions();
        setTransactions(response.data || []);
        
      } catch (err) {
        console.error('Error fetching transactions:', err);
        setError('Failed to load transactions. Please try again later.');
      } finally {
        setLoading(false);
      }
    };
    
    fetchTransactions();
  }, []);

  const handleSearch = (event: React.ChangeEvent<HTMLInputElement>) => {
    setSearchTerm(event.target.value);
  };

  const handleTypeChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setTransactionType(event.target.value);
  };

  const filteredTransactions = transactions.filter((transaction: any) => {
    // Filter by search term
    const matchesSearch = transaction.description?.toLowerCase().includes(searchTerm.toLowerCase()) || 
                         transaction.transactionId.toString().includes(searchTerm);
    
    // Filter by transaction type
    const matchesType = transactionType === 'ALL' || transaction.transactionType === transactionType;
    
    // Filter by date range
    let matchesDateRange = true;
    if (startDate) {
      matchesDateRange = matchesDateRange && new Date(transaction.date) >= startDate;
    }
    if (endDate) {
      matchesDateRange = matchesDateRange && new Date(transaction.date) <= endDate;
    }
    
    return matchesSearch && matchesType && matchesDateRange;
  });

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
        Transaction History
      </Typography>
      
      <Card elevation={0} sx={{ mb: 4, borderRadius: 3, border: `1px solid ${theme.palette.divider}` }}>
        <CardHeader 
          title="Filters" 
          titleTypographyProps={{ variant: 'h6', fontWeight: 'bold' }}
        />
        <Divider />
        <CardContent>
          <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '1fr 1fr 1fr 1fr' }, gap: 2, alignItems: 'center' }}>
            <TextField
              fullWidth
              label="Search Transactions"
              value={searchTerm}
              onChange={handleSearch}
              placeholder="Search by description or ID"
            />
            <TextField
              fullWidth
              select
              label="Transaction Type"
              value={transactionType}
              onChange={handleTypeChange}
            >
              <MenuItem value="ALL">All Types</MenuItem>
              <MenuItem value="CREDIT">Credit</MenuItem>
              <MenuItem value="DEBIT">Debit</MenuItem>
            </TextField>
            <LocalizationProvider dateAdapter={DateFnsAdapter}>
              <DatePicker
                label="Start Date"
                value={startDate}
                onChange={(newValue) => setStartDate(newValue)}
                slotProps={{ textField: { fullWidth: true } }}
              />
            </LocalizationProvider>
            <LocalizationProvider dateAdapter={DateFnsAdapter}>
              <DatePicker
                label="End Date"
                value={endDate}
                onChange={(newValue) => setEndDate(newValue)}
                slotProps={{ textField: { fullWidth: true } }}
              />
            </LocalizationProvider>
          </Box>
        </CardContent>
      </Card>
      
      <Card elevation={0} sx={{ borderRadius: 3, border: `1px solid ${theme.palette.divider}` }}>
        <CardHeader 
          title={`Transactions (${filteredTransactions.length})`}
          titleTypographyProps={{ variant: 'h6', fontWeight: 'bold' }}
          action={
            <Button variant="outlined">Export CSV</Button>
          }
        />
        <Divider />
        <CardContent>
          {filteredTransactions.length > 0 ? (
            <TableContainer component={Paper} elevation={0}>
              <Table sx={{ minWidth: 650 }}>
                <TableHead>
                  <TableRow>
                    <TableCell>Transaction ID</TableCell>
                    <TableCell>Date</TableCell>
                    <TableCell>Description</TableCell>
                    <TableCell>Type</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell align="right">Amount</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {filteredTransactions.map((transaction: any) => (
                    <TableRow
                      key={transaction.transactionId}
                      sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                    >
                      <TableCell component="th" scope="row">
                        {transaction.transactionId}
                      </TableCell>
                      <TableCell>{new Date(transaction.date).toLocaleDateString()}</TableCell>
                      <TableCell>{transaction.description || `Transaction #${transaction.transactionId}`}</TableCell>
                      <TableCell>
                        <Chip 
                          label={transaction.transactionType} 
                          size="small"
                          sx={{ 
                            bgcolor: transaction.transactionType === 'CREDIT' 
                              ? theme.palette.success.light 
                              : theme.palette.info.light,
                            color: transaction.transactionType === 'CREDIT' 
                              ? theme.palette.success.dark 
                              : theme.palette.info.dark,
                          }} 
                        />
                      </TableCell>
                      <TableCell>
                        <Chip 
                          label={transaction.status} 
                          size="small"
                          sx={{ 
                            bgcolor: theme.palette.success.light,
                            color: theme.palette.success.dark
                          }} 
                        />
                      </TableCell>
                      <TableCell align="right">
                        <Typography 
                          variant="body2" 
                          sx={{ 
                            fontWeight: 'bold',
                            color: transaction.transactionType === 'CREDIT' 
                              ? theme.palette.success.main 
                              : theme.palette.error.main
                          }}
                        >
                          {transaction.transactionType === 'CREDIT' ? '+' : '-'}
                          ${Math.abs(transaction.amount).toLocaleString('en-US', { minimumFractionDigits: 2 })}
                        </Typography>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          ) : (
            <Box sx={{ p: 3, textAlign: 'center' }}>
              <Typography variant="body1" color="text.secondary">
                No transactions found matching your filters.
              </Typography>
            </Box>
          )}
        </CardContent>
      </Card>
    </Box>
  );
};

export default Transactions;
