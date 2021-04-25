import React from 'react';
import { useUser, useUserDispatch } from '../components/authContext';
import { Redirect } from 'react-router-dom';

const HomeProfile = () => {
  const user = useUser();
  const dispatch = useUserDispatch();

  return (
    user
      ? (<div style={styles.container}>
          <div style={styles.userInfo}>
            <img
              src={`https://graph.facebook.com/${user.provider_id}/picture?type=square&width=150&height=150&access_token=${user.access_token}`}
              style={styles.userAvatar}
            />

            <div style={styles.userName}>{user.name}</div>

            <div style={styles.userID}><kbd>{user.provider_id}</kbd></div>

            <div style={styles.userEmail}>{user.email}</div>

            <div style={styles.userLogout}>
              <button style={styles.logoutButton} onClick={() => dispatch({ type: 'LOGOUT' })}>
                Đăng xuất
              </button>
            </div>
          </div>
        </div>)
      : <Redirect to="/" from="/profile" />
  )
}

const styles = {
  container: {
    flex: 1,
    backgroundColor: '#fff1ed',
    display: 'flex',
    fontFamily: 'sans-serif',
  },
  userInfo: {
    marginLeft: 'auto',
    marginRight: 'auto',
    marginTop: 100,
  },
  userAvatar: {
    borderRadius: '50%',
    border: '1px solid #ddd',
    padding: 5,
    backgroundColor: 'white',
    marginLeft: 'auto',
    marginRight: 'auto',
    display: 'block',
  },
  userName: {
    textAlign: 'center',
    marginTop: 10,
    fontSize: 20,
    fontWeight: 'bold',
  },
  userID: {
    textAlign: 'center',
    marginTop: 10,
    fontSize: 15,
  },
  userEmail: {
    textAlign: 'center',
    marginTop: 10,
    backgroundColor: '#333',
    color: 'white',
    padding: 3,
    borderRadius: 4,
  },
  userLogout: {
    textAlign: 'center',
    marginTop: 100,
  },
  logoutButton: {
    backgroundColor: '#007bff',
    border: 0,
    cursor: 'pointer',
    color: 'white',
    padding: 10,
    borderRadius: 4,
  }
}

export default HomeProfile;
