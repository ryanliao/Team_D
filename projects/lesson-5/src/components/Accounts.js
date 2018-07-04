import React from 'react';

<a href="#" className="pure-menu-link">{account}</a>

export default function Accounts({
    accounts=[],
    onSelectAccount
}) {
    return (
        <div className="pure-menu sidebae">
            <span className="pure-menu-heading">Accounts</span>

            <ul className="pure-menu-list">
                {
                    accounts.map(account => (
                        <li className="pure-menu-item" key={account} onClick={onSelectAccount}>
                            <a href="#" className="pure-menu-link">{account}</a>
                        </li>
                    ))
                }
            </ul>
        </div>
    );
}


