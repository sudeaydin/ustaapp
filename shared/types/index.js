// Shared TypeScript-like types for JavaScript
// We'll use JSDoc comments for type hints

/**
 * @typedef {Object} User
 * @property {number} id
 * @property {string} email
 * @property {string} phone
 * @property {string} user_type - 'customer' | 'craftsman' | 'admin'
 * @property {string} first_name
 * @property {string} last_name
 * @property {string} full_name
 * @property {string|null} profile_image
 * @property {boolean} is_active
 * @property {boolean} is_verified
 * @property {boolean} phone_verified
 * @property {boolean} email_verified
 * @property {string} created_at
 * @property {string} updated_at
 * @property {string|null} last_login
 */

/**
 * @typedef {Object} Category
 * @property {number} id
 * @property {string} name
 * @property {string|null} name_en
 * @property {string|null} description
 * @property {string|null} icon
 * @property {string|null} color
 * @property {boolean} is_active
 * @property {number} sort_order
 * @property {string} created_at
 * @property {string} updated_at
 */

/**
 * @typedef {Object} Service
 * @property {number} id
 * @property {number} craftsman_id
 * @property {number} category_id
 * @property {string} title
 * @property {string} description
 * @property {number} price_min
 * @property {number} price_max
 * @property {string} price_unit - 'per_hour' | 'per_day' | 'per_job' | 'per_m2'
 * @property {boolean} is_active
 * @property {string} created_at
 * @property {string} updated_at
 */

/**
 * @typedef {Object} Quote
 * @property {number} id
 * @property {number} customer_id
 * @property {number} craftsman_id
 * @property {number} service_id
 * @property {string} status - 'pending' | 'accepted' | 'rejected' | 'completed'
 * @property {string} description
 * @property {number|null} price
 * @property {string|null} notes
 * @property {string} created_at
 * @property {string} updated_at
 */

export const UserTypes = {
  CUSTOMER: 'customer',
  CRAFTSMAN: 'craftsman',
  ADMIN: 'admin'
}

export const QuoteStatus = {
  PENDING: 'pending',
  ACCEPTED: 'accepted',
  REJECTED: 'rejected',
  COMPLETED: 'completed'
}

export const PriceUnits = {
  PER_HOUR: 'per_hour',
  PER_DAY: 'per_day',
  PER_JOB: 'per_job',
  PER_M2: 'per_m2'
}
