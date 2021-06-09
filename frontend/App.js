import React from 'react';
import { UserContextProvider, useUser } from './components/authContext';
import UserProfile from './screens/UserProfile';
import Home from './screens/Home';
import { BrowserRouter as Router, Switch, Route, Redirect } from 'react-router-dom';

export default function App() {

  const PageContext = () => {
    const user = useUser();
    return (
      <Router>
        <Switch>
          <Route path="/profile" render={() => (
            user ? <UserProfile /> : <Redirect to="/" />
          )} />
          <Route path="/" render={() => (
            user ? <Redirect to="/profile" /> : <Home />
          )} />
        </Switch>
      </Router>
    );
  }

  return (
    <UserContextProvider>
      <PageContext />
    </UserContextProvider>
  );
}
