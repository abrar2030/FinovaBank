import { StyleSheet, Dimensions } from 'react-native';

const { width, height } = Dimensions.get('window');

// Define common styles and responsive utilities
export const commonStyles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16, // Add some padding
    backgroundColor: '#f5f5f5', // Example background color
  },
  titleText: {
    fontSize: width > 360 ? 24 : 20, // Adjust font size based on width
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  button: {
    backgroundColor: '#007bff',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 10,
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  // Add more common styles as needed
});

// Utility function for responsive sizing (example)
export const responsiveWidth = (percentage: number) => {
  return (width * percentage) / 100;
};

export const responsiveHeight = (percentage: number) => {
  return (height * percentage) / 100;
};

