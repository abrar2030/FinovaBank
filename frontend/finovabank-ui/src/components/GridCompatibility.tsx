// GridCompatibility.tsx
// A simplified compatibility layer for Material UI Grid component
import React from 'react';
import { Grid as MuiGrid, SxProps, Theme } from '@mui/material';

interface GridCompatibilityProps {
  children: React.ReactNode;
  container?: boolean;
  item?: boolean;
  xs?: number | boolean;
  sm?: number | boolean;
  md?: number | boolean;
  lg?: number | boolean;
  xl?: number | boolean;
  spacing?: number;
  sx?: SxProps<Theme>;
}

const GridCompatibility: React.FC<GridCompatibilityProps> = (props) => {
  const { children, item, ...other } = props;
  
  // In Material UI v7, the 'item' prop is no longer used
  // We simply pass all other props to the MuiGrid component
  return <MuiGrid {...other}>{children}</MuiGrid>;
};

export default GridCompatibility;
