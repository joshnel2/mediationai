# Bank Integration Guide

This guide explains how to set up bank transfers for the Crashout betting platform with minimal compliance requirements.

## Overview

We use a combination of Plaid (for bank connections) and Stripe (for ACH processing) to enable bank transfers. This approach minimizes compliance burden by leveraging established financial infrastructure providers who handle most regulatory requirements.

## Architecture

```
User → Plaid Link → Your App → Stripe ACH → User's Bank
```

## Benefits of This Approach

1. **Minimal Compliance**: Plaid and Stripe handle most compliance requirements
2. **No Money Transmitter License**: You're using payment processors, not holding funds
3. **Bank-Grade Security**: Both Plaid and Stripe are SOC 2 certified
4. **Fast Integration**: Can be set up in days, not months
5. **Lower Fees**: ACH transfers have much lower fees than cards

## Setup Instructions

### 1. Plaid Setup (Bank Connections)

1. Sign up at https://dashboard.plaid.com
2. Get your credentials:
   - Client ID
   - Secret Key
   - Choose "Sandbox" environment for testing
3. Enable products: Auth, Transactions
4. Set up webhook URL: `https://yourapi.com/webhooks/plaid`

### 2. Stripe Setup (Payment Processing)

1. Sign up at https://dashboard.stripe.com
2. Get your API keys:
   - Secret Key
   - Webhook Secret
3. Enable ACH payments in your dashboard
4. Set up webhook endpoint: `https://yourapi.com/webhooks/stripe`

### 3. Environment Variables

Add these to your `.env` file:

```bash
# Stripe
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Plaid
PLAID_CLIENT_ID=...
PLAID_SECRET=...
PLAID_ENV=sandbox
```

### 4. User Flow

1. **Connect Bank**: User clicks "Connect Bank" → Opens Plaid Link → Selects bank → Logs in
2. **Verify Account**: Plaid verifies the account and returns a token
3. **Create Payment**: Your app exchanges the token for a Stripe bank account token
4. **Process Transfer**: Stripe processes the ACH transfer (1-3 business days)

## Compliance Considerations

### What You DON'T Need:
- Money Transmitter License (you're using payment processors)
- Complex KYC/AML systems (handled by Stripe)
- Bank partnerships (handled by Plaid/Stripe)

### What You DO Need:
- Terms of Service mentioning payment processing
- Privacy Policy covering financial data
- Age verification (18+ for gambling)
- Responsible gambling disclaimers

### Best Practices:
1. **Instant vs Standard**: Offer both instant (debit card, 2.5% fee) and standard (ACH, no fee) options
2. **Limits**: Set reasonable deposit/withdrawal limits
3. **Fraud Prevention**: Use Stripe's built-in fraud detection
4. **Record Keeping**: Store transaction records for 7 years

## Fee Structure

### ACH (Bank Transfer):
- **Your Cost**: ~$0.80 per transaction (Stripe)
- **User Sees**: FREE
- **Processing Time**: 1-3 business days

### Instant Deposit (Debit Card):
- **Your Cost**: 2.9% + $0.30 (Stripe)
- **User Sees**: 2.5% fee
- **Processing Time**: Instant

## Testing

### Test Bank Accounts (Plaid Sandbox):
- Username: `user_good`
- Password: `pass_good`
- Bank: Any bank in the list

### Test Card Numbers (Stripe):
- Success: `4242 4242 4242 4242`
- Decline: `4000 0000 0000 0002`

## API Endpoints

### Connect Bank:
```
POST /api/connect-bank/link-token
GET /api/bank-accounts
POST /api/connect-bank/exchange-token
```

### Deposits:
```
POST /api/deposit/bank      # ACH transfer (no fees, 1-3 days)
POST /api/deposit/instant   # Debit card (2.5% fee, instant)
```

### Webhooks:
```
POST /webhooks/stripe   # Payment confirmations
POST /webhooks/plaid    # Bank account updates
```

## Security Notes

1. **Never store** bank credentials - only Plaid access tokens
2. **Always verify** webhook signatures
3. **Use HTTPS** for all API calls
4. **Implement rate limiting** on deposit endpoints
5. **Monitor for suspicious** activity patterns

## Going Live Checklist

- [ ] Upgrade Plaid to Production environment
- [ ] Upgrade Stripe to Live mode
- [ ] Update all API keys in production
- [ ] Test with real bank account (small amount)
- [ ] Set up monitoring and alerts
- [ ] Review and update limits
- [ ] Ensure legal disclaimers are in place

## Support Resources

- Plaid Docs: https://plaid.com/docs
- Stripe ACH Guide: https://stripe.com/docs/ach
- Our API Docs: See `/docs` endpoint

## Common Issues

### "Bank not supported"
Some smaller banks/credit unions might not be supported by Plaid. Offer alternative payment methods.

### "Microdeposit verification required"
For some banks, Stripe needs to verify with microdeposits (takes 1-2 days). This is normal.

### "Payment failed"
Usually due to insufficient funds or closed account. Handle gracefully with clear user messaging.