// filepath: /Users/asiyanmuhammedicloud.com/Documents/Native/Ustam/ustaapp/mobile/app/index.js
import React from 'react';
import { View, StyleSheet } from 'react-native';
import { WebView } from 'react-native-webview';

export default function Page() {
  return (
    <View style={styles.container}>
      <WebView source={{ uri: 'http://localhost:3000' }} style={styles.webview} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  webview: {
    flex: 1,
  },
});