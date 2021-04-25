import React, { useState } from 'react';
import FacebookLogin from 'react-facebook-login';
import { BACKEND_API, FACEBOOK_APP_ID } from '@env';
import { useUserDispatch } from '../components/authContext';

const Home = () => {
  const dispatch = useUserDispatch();
  const [authenticating, setAuthenticating] = useState(false);

  const handleFacebookResponse = async (response) => {
    setAuthenticating(true);
    if (!response.id) {
      return
    }

    const url = new URL(BACKEND_API + '/session_token');
    const api = await fetch(url, {
      method: 'POST',
      body: JSON.stringify({
        provider_id: response.id,
        name: response.name,
        email: response.email,
        access_token: response.accessToken
      }),
      headers: { 'Content-Type': 'application/json' }
    });
    const { user } = await api.json();
    user && dispatch({ type: 'LOGIN', payload: user });
  }

  return (
    authenticating
      ? <div style={styles.container}>
          <div style={styles.authMessage}>Authenticating...</div>
        </div>
      : <div style={styles.container}>
          <FacebookLogin
            appId={FACEBOOK_APP_ID}
            fields="name,email,picture"
            callback={handleFacebookResponse}
            textButton={"Đăng nhập Facebook"}
            icon="fa-facebook-square"
            size="medium"
            containerStyle={styles.loginButtonContainer}
            buttonStyle={styles.loginButton}
          />
        </div>
  )
}

const styles = {
  container: {
    flex: 1,
    backgroundColor: '#fff1ed',
    display: 'flex',
  },
  loginButtonContainer: {
    margin: 'auto auto',
  },
  loginButton: {
    textTransform: 'none',
    borderRadius: 4,
  },
  authMessage: {
    margin: 'auto auto',
    fontFamily: 'sans-serif',
  }
}

export default Home;
