#ifndef __AL_SINGLETON_H
#define __AL_SINGLETON_H 1

#include <QMutex>
#include <QScopedPointer>
#include <QDebug>

#define AL_DECLARE_SINGLETON(__class) 					\
	public:												\
		static __class *instance()						\
		{ 												\
			static QMutex m_instance_mutex;				\
			static QScopedPointer<__class> m_instance;	\
														\
			if (Q_UNLIKELY(!m_instance)) {				\
				m_instance_mutex.lock(); 				\
				if (!m_instance) {						\
					m_instance.reset(new __class);		\
				}										\
				m_instance_mutex.unlock();				\
			}											\
														\
			return m_instance.data();					\
		}												\
														\
	private:											\
		Q_DISABLE_COPY(__class);
#endif

