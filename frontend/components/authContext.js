import React, { createContext, useContext, useReducer, useEffect } from 'react';
import Cookies from 'universal-cookie';
import { BACKEND_API } from '@env';

const cookies = new Cookies();
const userContext = createContext();
const userDispatchContext = createContext();
const initialState = null;

const reducer = (_state, action) => {
  switch(action.type) {
    case 'LOGIN':
      cookies.set('auth', action.payload.access_token, { path: '/' });
      return action.payload;
    case 'LOGOUT':
      cookies.remove('auth');
      return null;
    default:
      throw new Error(`Unknown action: ${action.type}`);
  }
}

export const UserContextProvider = (props) => {
  const [state, dispatch] = useReducer(reducer, initialState);
  const authUrl = new URL(BACKEND_API + '/session_token/auth');

  useEffect(() => {
    const token = cookies.get('auth');
    if (!token) {
      return;
    }
    handleVerifyUser(token);
  }, [])

  const handleVerifyUser = async (token) => {
    try {
      const response = await fetch(authUrl, {
        method: 'POST',
        body: JSON.stringify({ token: token }),
        headers: { 'Content-Type': 'application/json' }
      });
      const { user } = await response.json();
      user && dispatch({ type: 'LOGIN', payload: user });
    } catch(error) {
      console.log(error)
    }
  }

  return (
    <userDispatchContext.Provider value={dispatch}>
      <userContext.Provider value={state}>
        {props.children}
      </userContext.Provider>
    </userDispatchContext.Provider>
  )
}

export const useUser = () => useContext(userContext);
export const useUserDispatch = () => useContext(userDispatchContext);
