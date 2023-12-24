part of 'json_tree_controller.dart';

const String _exampleJson = '''
{
    "page": 1,
    "perPage": 20,
    "pages": 1,
    "total": 9,
    "data": [
         {
          "address": "n2u5ZbGrpUT7NFDcrS53fPM3T7R9gSx19Y",
          "total_received": 0,
          "total_sent": 0,
          "balance": 0,
          "unconfirmed_balance": 0,
          "final_balance": 0,
          "n_tx": 0,
          "unconfirmed_n_tx": 0,
          "final_n_tx": 0
        } 
    ]
}
''';
// const String _exampleJson = '''
// {
//     "page": 1,
//     "perPage": 20,
//     "pages": 1,
//     "total": 9,
//     "data": [
//         {
//             "id": "ACC.RUB.orion.Tinkoff.0",
//             "currencyId": "RUB",
//             "balance": 865.00000000,
//             "pendingWithdrawals": 0,
//             "number": "2200206322716344",
//             "name": "Василий Васильевич Т.",
//             "opened": true,
//             "created": "0001-01-01T00:00:00",
//             "branchId": "default",
//             "clientId": "cli-orion.Tinkoff",
//             "clientName": "Tinkoff bank",
//             "type": "active",
//             "subType": "bank",
//             "decimalPlaces": 2,
//             "isCrypto": false,
//             "isBinSponsor": false,
//             "code": "tinkoff",
//             "balanceBase": 0
//         }
//     ]
// }
// ''';



// const String _exampleJson = '''
// {
//   "transactionId": "string",
//   "reject": {
//     "clientId": "string",
//     "clientName": "string",
//     "reason": "string"
//   },
//   "cardInOut": {
//     "account": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "accountSufixCode": "system",
//     "externalId": "string",
//     "state": "successful",
//     "message": "string",
//     "receiptUrl": "string",
//     "stamp": "string",
//     "cardHolder": "string",
//     "last4": "string",
//     "brand": "string",
//     "issuer": "string"
//   },
//   "p2pCard": {
//     "account": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "accountSufixCode": "system",
//     "cardHolder": "string",
//     "pan": "string",
//     "extraCode": "string"
//   },
//   "cardPay": {
//     "account": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "cardTransactionId": "string",
//     "cardMemo": "string",
//     "billingCurrencyId": "string",
//     "billingAmount": 0,
//     "transactionCurrencyId": "string",
//     "transactionAmount": 0,
//     "failureReason": "string",
//     "status": "pending",
//     "type": "authorization"
//   },
//   "cash": {
//     "account": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "phoneNumber": "string",
//     "name": "string",
//     "dateTime": "string",
//     "address": "string",
//     "comment": "string"
//   },
//   "crypto": {
//     "account": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "txHash": "string",
//     "txHashUrl": "string",
//     "blockchain": "eth",
//     "from": "string",
//     "to": "string",
//     "amountUsd": 0,
//     "transactionFeeEth": 0,
//     "transactionFeeUsd": 0,
//     "ethToUsdPrice": 0,
//     "tokenToUsdPrice": 0,
//     "fromFullAddress": "string",
//     "toFullAddress": "string",
//     "comment": "string"
//   },
//   "cryptoFee": {
//     "account": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "txHash": "string",
//     "txHashUrl": "string",
//     "blockchain": "eth",
//     "amountUsd": 0,
//     "transactionFeeEth": 0,
//     "transactionFeeUsd": 0,
//     "ethToUsdPrice": 0,
//     "tokenToUsdPrice": 0
//   },
//   "deposit": {
//     "account": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "senderAccountName": "string",
//     "senderAccountNumber": "string",
//     "senderRoutingNumber": "string",
//     "senderAddress": "string",
//     "senderCountryId": "string",
//     "senderReference": "string",
//     "senderInstitution": "string",
//     "email": "string",
//     "emailSent": true,
//     "emailSentSubject": "string",
//     "emailSentBody": "string",
//     "emailSentTs": "2023-11-17T04:34:47.429Z"
//   },
//   "exchange": {
//     "stableSide": "none",
//     "fromAccount": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "toAccount": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "sellAmount": 0,
//     "buyAmount": 0
//   },
//   "payment": {
//     "account": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "recipientId": "string",
//     "recipientName": "string",
//     "reason": "string",
//     "reference": "string",
//     "paymentShortReference": "string",
//     "paymentId": "string",
//     "status": "string",
//     "paymentPurposeCodeId": "string"
//   },
//   "toClient": {
//     "fromClientId": "string",
//     "fromClientName": "string",
//     "fromAccount": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "toAccount": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "toClientId": "string",
//     "toClientName": "string",
//     "amount": 0
//   },
//   "transfer": {
//     "fromAccount": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "toAccount": {
//       "id": "string",
//       "currencyId": "string",
//       "number": "string",
//       "balance": 0,
//       "decimalPlaces": 0
//     },
//     "amount": 0
//   }
// }
// ''';
