// Modern Transactions page with enhanced UI
import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Button,
  Divider,
  CircularProgress,
  Alert,
  useTheme,
  Tabs,
  Tab,
  TextField,
  InputAdornment,
  IconButton,
  Avatar,
  Chip,
  Menu,
  MenuItem,
  ListItemIcon,
  ListItemText
} from '@mui/material';
import {
  Search as SearchIcon,
  FilterList as FilterListIcon,
  ArrowUpward as ArrowUpwardIcon,
  ArrowDownward as ArrowDownwardIcon,
  MoreVert as MoreVertIcon,
  Receipt as ReceiptIcon,
  Delete as DeleteIcon,
  Edit as EditIcon,
  Download as DownloadIcon,
  Add as AddIcon,
  AttachMoney as AttachMoneyIcon,
  DateRange as DateRangeIcon
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { transactionAPI } from '../services/api';
import GridCompatibility from '../components/GridCompatibility';

const Transactions: React.FC = () => {
  const theme = useTheme();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [transactions, setTransactions] = useState([]);
  const [activeTab, setActiveTab] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [selectedTransaction, setSelectedTransaction] = useState<any>(null);
  
  useEffect(() => {
    const fetchTransactions = async () => {
      try {
        setLoading(true);
        setError(null);
        
        // Fetch transactions
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
  
  const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
    setActiveTab(newValue);
  };
  
  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>, transaction: any) => {
    setAnchorEl(event.currentTarget);
    setSelectedTransaction(transaction);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setSelectedTransaction(null);
  };
  
  const filteredTransactions = transactions.filter((transaction: any) => {
    // Filter by tab
    if (activeTab === 1 && transaction.transactionType !== 'CREDIT') return false;
    if (activeTab === 2 && transaction.transactionType !== 'DEBIT') return false;
    
    // Filter by search query
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      return (
        (transaction.description && transaction.description.toLowerCase().includes(query)) ||
        (transaction.category && transaction.category.toLowerCase().includes(query)) ||
        (transaction.amount && transaction.amount.toString().includes(query))
      );
    }
    
    return true;
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
      {/* Transactions Header */}
      <Box 
        sx={{ 
          mb: 4, 
          p: 4, 
          borderRadius: 3, 
          background: 'linear-gradient(135deg, rgba(37, 99, 235, 0.1) 0%, rgba(124, 58, 237, 0.1) 100%)',
          display: 'flex',
          flexDirection: { xs: 'column', md: 'row' },
          alignItems: { xs: 'flex-start', md: 'center' },
          justifyContent: 'space-between',
          gap: 2
        }}
      >
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, mb: 1 }}>
            Transactions
          </Typography>
          <Typography variant="body1" color="text.secondary">
            View and manage all your account transactions
          </Typography>
        </Box>
        <Box sx={{ display: 'flex', gap: 2 }}>
          <Button 
            variant="contained" 
            startIcon={<AttachMoneyIcon />}
            onClick={() => navigate('/transfer')}
          >
            New Transfer
          </Button>
          <Button 
            variant="outlined" 
            startIcon={<DownloadIcon />}
          >
            Export
          </Button>
        </Box>
      </Box>
      
      {/* Filters and Search */}
      <Paper
        elevation={0}
        sx={{
          p: 3,
          borderRadius: 3,
          border: `1px solid ${theme.palette.divider}`,
          mb: 3
        }}
      >
        <GridCompatibility container spacing={3} alignItems="center">
          <GridCompatibility xs={12} md={6}>
            <TextField
              fullWidth
              placeholder="Search transactions..."
              variant="outlined"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <SearchIcon color="action" />
                  </InputAdornment>
                ),
              }}
              size="small"
            />
          </GridCompatibility>
          
          <GridCompatibility xs={12} md={6}>
            <Box sx={{ display: 'flex', gap: 2, justifyContent: { xs: 'flex-start', md: 'flex-end' } }}>
              <Button
                variant="outlined"
                startIcon={<DateRangeIcon />}
                size="medium"
              >
                Date Range
              </Button>
              <Button
                variant="outlined"
                startIcon={<FilterListIcon />}
                size="medium"
              >
                Filters
              </Button>
            </Box>
          </GridCompatibility>
        </GridCompatibility>
      </Paper>
      
      {/* Tabs Navigation */}
      <Box sx={{ mb: 3 }}>
        <Tabs 
          value={activeTab} 
          onChange={handleTabChange}
          sx={{ 
            mb: 2,
            '& .MuiTabs-indicator': {
              backgroundColor: theme.palette.primary.main,
              height: 3,
              borderRadius: '3px 3px 0 0',
            }
          }}
        >
          <Tab 
            label="All Transactions" 
            sx={{ 
              fontWeight: 600,
              '&.Mui-selected': {
                color: theme.palette.primary.main,
              }
            }}
          />
          <Tab 
            label="Income" 
            sx={{ 
              fontWeight: 600,
              '&.Mui-selected': {
                color: theme.palette.primary.main,
              }
            }}
          />
          <Tab 
            label="Expenses" 
            sx={{ 
              fontWeight: 600,
              '&.Mui-selected': {
                color: theme.palette.primary.main,
              }
            }}
          />
        </Tabs>
      </Box>
      
      {/* Transactions List */}
      <Paper
        elevation={0}
        sx={{
          borderRadius: 3,
          border: `1px solid ${theme.palette.divider}`,
          overflow: 'hidden'
        }}
      >
        <Box sx={{ p: 3, borderBottom: `1px solid ${theme.palette.divider}` }}>
          <Typography variant="subtitle1" fontWeight={600}>
            {activeTab === 0 ? 'All Transactions' : activeTab === 1 ? 'Income' : 'Expenses'}
            {filteredTransactions.length > 0 && (
              <Typography component="span" color="text.secondary" sx={{ ml: 1, fontWeight: 400 }}>
                ({filteredTransactions.length})
              </Typography>
            )}
          </Typography>
        </Box>
        
        {filteredTransactions.length > 0 ? (
          <Box>
            {filteredTransactions.map((transaction: any) => (
              <Box
                key={transaction.transactionId}
                sx={{
                  p: 3,
                  borderBottom: `1px solid ${theme.palette.divider}`,
                  '&:last-child': {
                    borderBottom: 'none',
                  },
                  '&:hover': {
                    bgcolor: 'rgba(0, 0, 0, 0.01)',
                  },
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                }}
              >
                <Box sx={{ display: 'flex', alignItems: 'center' }}>
                  <Avatar
                    sx={{
                      width: 48,
                      height: 48,
                      bgcolor: transaction.transactionType === 'CREDIT' 
                        ? `${theme.palette.success.main}15` 
                        : `${theme.palette.error.main}15`,
                      color: transaction.transactionType === 'CREDIT' 
                        ? theme.palette.success.main 
                        : theme.palette.error.main,
                      mr: 2,
                    }}
                  >
                    {transaction.transactionType === 'CREDIT' ? <ArrowUpwardIcon /> : <ArrowDownwardIcon />}
                  </Avatar>
                  
                  <Box>
                    <Typography variant="subtitle1" fontWeight={600}>
                      {transaction.description || `Transaction #${transaction.transactionId}`}
                    </Typography>
                    <Box sx={{ display: 'flex', alignItems: 'center', mt: 0.5 }}>
                      <Typography variant="body2" color="text.secondary">
                        {new Date(transaction.date).toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                          year: 'numeric',
                        })}
                      </Typography>
                      
                      {transaction.category && (
                        <>
                          <Box 
                            sx={{ 
                              width: 4, 
                              height: 4, 
                              borderRadius: '50%', 
                              bgcolor: 'text.secondary',
                              mx: 1 
                            }} 
                          />
                          <Chip
                            label={transaction.category}
                            size="small"
                            sx={{
                              height: 24,
                              fontSize: '0.75rem',
                              bgcolor: 'rgba(0, 0, 0, 0.04)',
                              color: 'text.secondary',
                            }}
                          />
                        </>
                      )}
                    </Box>
                  </Box>
                </Box>
                
                <Box sx={{ display: 'flex', alignItems: 'center' }}>
                  <Typography
                    variant="subtitle1"
                    fontWeight={600}
                    color={transaction.transactionType === 'CREDIT' ? 'success.main' : 'error.main'}
                    sx={{ mr: 2 }}
                  >
                    {transaction.transactionType === 'CREDIT' ? '+' : '-'}${Math.abs(transaction.amount).toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </Typography>
                  
                  <IconButton
                    size="small"
                    onClick={(e) => handleMenuOpen(e, transaction)}
                  >
                    <MoreVertIcon />
                  </IconButton>
                </Box>
              </Box>
            ))}
          </Box>
        ) : (
          <Box sx={{ p: 4, textAlign: 'center' }}>
            <Typography variant="body1" color="text.secondary" sx={{ mb: 2 }}>
              {searchQuery 
                ? 'No transactions match your search criteria.' 
                : activeTab === 0 
                  ? 'No transactions found.' 
                  : activeTab === 1 
                    ? 'No income transactions found.' 
                    : 'No expense transactions found.'
              }
            </Typography>
            {!searchQuery && (
              <Button 
                variant="contained" 
                startIcon={<AddIcon />}
                onClick={() => navigate('/transfer')}
              >
                New Transaction
              </Button>
            )}
          </Box>
        )}
      </Paper>
      
      {/* Transaction Menu */}
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleMenuClose}
        PaperProps={{
          sx: {
            mt: 1,
            boxShadow: '0px 8px 20px rgba(0, 0, 0, 0.1)',
            borderRadius: 2,
          }
        }}
        transformOrigin={{ horizontal: 'right', vertical: 'top' }}
        anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
      >
        <MenuItem onClick={() => { 
          handleMenuClose();
          navigate(`/transactions/${selectedTransaction?.transactionId}`);
        }}>
          <ListItemIcon>
            <ReceiptIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>View Details</ListItemText>
        </MenuItem>
        <MenuItem onClick={handleMenuClose}>
          <ListItemIcon>
            <EditIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>Edit Category</ListItemText>
        </MenuItem>
        <MenuItem onClick={handleMenuClose}>
          <ListItemIcon>
            <DownloadIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>Download Receipt</ListItemText>
        </MenuItem>
        <Divider />
        <MenuItem onClick={handleMenuClose} sx={{ color: 'error.main' }}>
          <ListItemIcon sx={{ color: 'error.main' }}>
            <DeleteIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>Delete</ListItemText>
        </MenuItem>
      </Menu>
    </Box>
  );
};

export default Transactions;
